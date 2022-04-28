// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

protocol ChargePresetServiceProtocol {
    func chargePresetAccount(usingListResultURL listResultURL: URL, completion: @escaping (_ result: CheckoutResult) -> Void, authenticationChallengeReceived: @escaping (_ url: URL) -> Void)
}

final class ChargePresetService: ChargePresetServiceProtocol {
    private var redirectCallbackHandler: RedirectCallbackHandler?
    private var paymentService: PaymentService?
    private let connection: Connection = URLSessionConnection()
    private let riskService: RiskService

    private var completionBlock: ((_ result: CheckoutResult) -> Void)?
    private var authenticationChallengeReceivedBlock: ((_ url: URL) -> Void)?

    init(riskService: RiskService) {
        self.riskService = riskService
    }

    func chargePresetAccount(usingListResultURL listResultURL: URL, completion: @escaping (_ result: CheckoutResult) -> Void, authenticationChallengeReceived: @escaping (_ url: URL) -> Void) {
        self.completionBlock = completion
        self.authenticationChallengeReceivedBlock = authenticationChallengeReceived

        getListResult(from: listResultURL) { [weak self] result in
            switch result {
            case .success(let listResult):
                do {
                    if let riskProviderParameters = listResult.riskProviders {
                        self?.riskService.loadRiskProviders(withParameters: riskProviderParameters)
                    }

                    try self?.chargePresetAccount(from: listResult)
                } catch {
                    let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                    let result = CheckoutResult(operationResult: .failure(errorInfo))

                    DispatchQueue.main.async {
                        self?.completionBlock?(result)
                        self?.completionBlock = nil
                        self?.authenticationChallengeReceivedBlock = nil
                    }
                }
            case .failure(let error):
                let errorInfo: ErrorInfo = {
                    if let errorInfo = error as? ErrorInfo { return errorInfo }
                    return CustomErrorInfo.createClientSideError(from: error)
                }()

                let result = CheckoutResult(operationResult: .failure(errorInfo))

                DispatchQueue.main.async {
                    self?.completionBlock?(result)
                    self?.completionBlock = nil
                    self?.authenticationChallengeReceivedBlock = nil
                }
            }
        }
    }

    private func getListResult(from url: URL, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        let getListResult = NetworkRequest.GetListResult(url: url)
        let getListResultOperation = SendRequestOperation(connection: connection, request: getListResult)
        getListResultOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let listResult):
                completion(.success(listResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        getListResultOperation.start()
    }

    /// - Throws: `InternalError`
    private func chargePresetAccount(from listResult: ListResult) throws {
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
            let result = CheckoutResult(operationResult: result)

            DispatchQueue.main.async { [weak self] in
                self?.completionBlock?(result)
                self?.completionBlock = nil
                self?.authenticationChallengeReceivedBlock = nil
            }
        case .redirect(let url):
            DispatchQueue.main.async { [weak self] in
                self?.authenticationChallengeReceivedBlock?(url)
                self?.authenticationChallengeReceivedBlock = nil
            }
        }
    }
}
