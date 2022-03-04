// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import SafariServices

#if canImport(Risk)
import Risk
#endif

@objc public class ChargePresetService: NSObject {
    @objc public weak var delegate: ChargePresetDelegate?

    private var redirectCallbackHandler: RedirectCallbackHandler?
    private var paymentService: PaymentService?
    private let connection: Connection
    private var presentedViewController: UIViewController?

    public let riskRegistry = RiskProviderRegistry()

    @objc public override convenience init() {
        let connection = URLSessionConnection()
        self.init(connection: connection)
    }

    internal init(connection: Connection) {
        self.connection = connection
        super.init()
    }

    @objc public func chargePresetAccount(usingListResultURL listResultURL: URL) {
        getListResult(from: listResultURL) { result in
            switch result {
            case .success(let listResult):
                do {
                    var riskService = RiskService(registry: self.riskRegistry)

                    if let riskProviders = listResult.riskProviders {
                        riskService.loadRiskProviders(using: riskProviders)
                    }

                    try self.chargePresetAccount(from: listResult, riskService: riskService)
                } catch {
                    let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                    let paymentResult = PaymentResult(operationResult: .failure(errorInfo))
                    DispatchQueue.main.async {
                        self.delegate?.chargePresetService(didReceivePaymentResult: paymentResult, viewController: nil)
                    }
                }
            case .failure(let error):
                let errorInfo: ErrorInfo = {
                    if let errorInfo = error as? ErrorInfo { return errorInfo }
                    return CustomErrorInfo.createClientSideError(from: error)
                }()
                let paymentResult = PaymentResult(operationResult: .failure(errorInfo))
                DispatchQueue.main.async {
                    self.delegate?.chargePresetService(didReceivePaymentResult: paymentResult, viewController: nil)
                }
            }
        }
    }

    private func getListResult(from url: URL, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        let getListResult = NetworkRequest.GetListResult(url: url)
        let getListResultOperation = SendRequestOperation(connection: connection, request: getListResult)
        getListResultOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let listResult): completion(.success(listResult))
            case .failure(let error): completion(.failure(error))
            }
        }
        getListResultOperation.start()
    }

    /// - Throws: `InternalError`
    private func chargePresetAccount(from listResult: ListResult, riskService: RiskService) throws {
        guard let presetAccount = listResult.presetAccount else {
            let error = InternalError(description: "Payment session doesn't contain preset account")
            throw error
        }

        guard
            let operationType = listResult.operationType,
            operationType == "PRESET"
        else {
            let error = InternalError(description: "List result doesn't contain operation type or operation type is not PRESET")
            throw error
        }

        guard let operationURL = presetAccount.links["operation"] else {
            let error = InternalError(description: "Preset account doesn't contain links.operation property, unable to charge")
            throw error
        }

        let riskData = riskService.collectRiskData()

        let paymentRequest = PaymentRequest(networkCode: presetAccount.code, operationURL: operationURL, operationType: operationType, providerRequests: riskData)

        let factory = PaymentServicesFactory(connection: connection)
        factory.registerServices()
        guard let paymentService = factory.createPaymentService(forNetworkCode: presetAccount.code, paymentMethod: presetAccount.method) else {
            let error = InternalError(description: "Network code or payment method is not supported by any of payment services")
            throw error
        }
        self.paymentService = paymentService
        paymentService.delegate = self
        paymentService.send(operationRequest: paymentRequest)
    }
}

extension ChargePresetService: PaymentServiceDelegate {
    func paymentService(didReceiveResponse response: PaymentServiceParsedResponse, for request: OperationRequest) {
        paymentService = nil

        switch response {
        case .result(let result):
            let paymentResult = PaymentResult(operationResult: result)
            DispatchQueue.main.async {
                self.delegate?.chargePresetService(didReceivePaymentResult: paymentResult, viewController: self.presentedViewController)
            }
        case .redirect(let url):
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.delegate = self
            self.presentedViewController = safariViewController

            DispatchQueue.main.async {
                self.delegate?.chargePresetService(didRequestPresenting: safariViewController)
            }
        }
    }
}

extension ChargePresetService: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        NotificationCenter.default.post(
            name: RedirectCallbackHandler.didFailReceivingPaymentResultURLNotification,
            object: nil,
            userInfo: [RedirectCallbackHandler.operationTypeUserInfoKey: "PRESET"]
        )
    }
}
