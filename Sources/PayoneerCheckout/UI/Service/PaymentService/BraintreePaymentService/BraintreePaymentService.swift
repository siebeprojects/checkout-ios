// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import SafariServices
import BraintreeApplePay
import PassKit

class BraintreePaymentService: NSObject, PaymentService {
    // TODO: Should be implemented without optionals
    private var braintreeClient: BTAPIClient?
    private var onSelectRequest: OnSelectRequest?

    private var paymentController: PKPaymentAuthorizationController?

    // MARK: - Static methods
    static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        return networkCode == "APPLEPAY" && paymentMethod == "WALLET" && PKPaymentAuthorizationViewController.canMakePayments()

        // TODO: We should get this information after onSelect
//        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.chinaUnionPay, .visa], capabilities: .capability3DS)
    }

    // MARK: -

    weak var delegate: PaymentServiceDelegate?

    let connection: Connection
    private var redirectCallbackHandler: RedirectCallbackHandler?

    required init(using connection: Connection) {
        self.connection = connection
    }

    func send(operationRequest: OperationRequest) {
        guard let onSelectRequest = operationRequest as? OnSelectRequest else {
            let error = InternalError(description: "The first operation request should be onSelect")
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            self.delegate?.paymentService(didReceiveResponse: .result(.failure(errorInfo)), for: operationRequest)
            return
        }

        self.onSelectRequest = onSelectRequest

        onSelectRequest.send(using: connection) { result in
            switch result {
            case .success(let operationResult):
                let fabric = PaymentRequestFabric(operationResult: operationResult)
                fabric.createPaymentRequest { paymentRequestResult in
                    self.braintreeClient = fabric.braintreeClient
                    
                    switch paymentRequestResult {
                    case .success(let paymentRequest):
                        DispatchQueue.main.async {
                            // FIXME: Pyramid, force try
                            try! self.presentPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                        }
                    case .failure(let error):
                        let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                        self.delegate?.paymentService(didReceiveResponse: .result(.failure(errorInfo)), for: operationRequest)
                    }
                }
            case .failure(let error):
                let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                self.delegate?.paymentService(didReceiveResponse: .result(.failure(errorInfo)), for: operationRequest)
            }
        }
    }

    private func presentPaymentAuthorizationViewController(paymentRequest: PKPaymentRequest) throws {
        // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
        // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
        let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        self.paymentController = paymentController
        paymentController.delegate = self
        paymentController.present()
    }

    private func send(paymentRequest: PaymentRequest, addingBraintreeNonce braintreeNonce: String, completion: @escaping ((Bool) -> Void)) {
//        let parametersAddingNonce: [Parameter] = {
//            let nonceParameter = Parameter(name: "nonce", value: braintreeNonce)
//
//            var newParameters = providerParameters.parameters ?? []
//            newParameters.append(nonceParameter)
//            return newParameters
//        }()

        let nonceParameter = Parameter(name: "nonce", value: braintreeNonce)

        let providerParametersAddingNonce = ProviderParameters(
            providerCode: paymentRequest.networkCode,
            providerType: nil,
            parameters: [nonceParameter])

        let paymentRequestAddingNonce: PaymentRequest = {
            var updatedPaymentRequest = paymentRequest
            updatedPaymentRequest.providerRequest = providerParametersAddingNonce
            return updatedPaymentRequest
        }()

        paymentRequestAddingNonce.send(using: connection) { result in
            // FIXME:
            switch result {
            case .success: completion(true)
            case .failure: completion(false)
            }

            let parser = BasicPaymentService.ResponseParser(operationType: paymentRequest.operationType, connectionType: type(of: self.connection.self))
            let parsedResponse = parser.parse(paymentRequestResponse: result)
            self.delegate?.paymentService(didReceiveResponse: parsedResponse, for: paymentRequest)
        }
    }
}

extension BraintreePaymentService: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        guard let braintreeClient = self.braintreeClient else {
            fatalError("BraintreeClient is not set")
        }

        guard let onSelectRequest = self.onSelectRequest else {
            fatalError("On select request wasn't set")
        }

        let applePayClient = BTApplePayClient(apiClient: braintreeClient)
        applePayClient.tokenizeApplePay(payment) { nonce, error in
            if let error = error {
                let errorInfo = CustomErrorInfo.createClientSideError(from: error)
                completion(.init(status: .failure, errors: nil))
                self.delegate?.paymentService(didReceiveResponse: .result(.failure(errorInfo)), for: onSelectRequest)
                return
            }

            guard let nonce = nonce else {
                let internalError = InternalError(description: "Braintree SDK error: error and nonce are nil")
                let errorInfo = CustomErrorInfo.createClientSideError(from: internalError)
                completion(.init(status: .failure, errors: nil))
                self.delegate?.paymentService(didReceiveResponse: .result(.failure(errorInfo)), for: onSelectRequest)
                return
            }

            self.send(paymentRequest: onSelectRequest.paymentRequest, addingBraintreeNonce: nonce.nonce) { success in
                // FIXME:
                if success {
                    completion(.init(status: .success, errors: nil))
                } else {
                    completion(.init(status: .failure, errors: nil))
                }
            }
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            self.paymentController = nil
        }
    }
}

extension BraintreePaymentService: Loggable {}
