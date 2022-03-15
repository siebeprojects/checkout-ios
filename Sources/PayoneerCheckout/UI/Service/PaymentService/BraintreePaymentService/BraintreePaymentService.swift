// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import SafariServices

class BraintreePaymentService: PaymentService {
    // MARK: - Static methods
    static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        return networkCode == "APPLEPAY" && paymentMethod == "WALLET"
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
            fatalError("⛔️ The first operation request should be onSelect")
        }

        operationRequest.send(using: connection) { result in
            self.handle(response: result, for: onSelectRequest)
        }
    }

    private func handle(response: Result<OperationResult, Error>, for onSelectRequest: OnSelectRequest) {
        switch response {
        case .success(let operationResult):
            operationResult.providerResponse?.providerCode
        case .failure(let error):
            if #available(iOS 14.0, *) {
                error.log(to: logger)
            }
        }
//        let parser = ResponseParser(operationType: request.operationType, connectionType: type(of: self.connection.self))
//        let response = parser.parse(paymentRequestResponse: response)
//
//        switch response {
//        case .result: break
//        case .redirect(let url):
//            if #available(iOS 14.0, *) {
//                logger.notice("Redirecting user to an external url: \(url.absoluteString, privacy: .private)")
//            }
//
//            let callbackHandler = RedirectCallbackHandler(for: request)
//            callbackHandler.delegate = self.delegate
//            callbackHandler.subscribeForNotification()
//
//            self.redirectCallbackHandler = callbackHandler
//        }
//
//        self.delegate?.paymentService(didReceiveResponse: response, for: request)
    }
}

extension BraintreePaymentService: Loggable {}
