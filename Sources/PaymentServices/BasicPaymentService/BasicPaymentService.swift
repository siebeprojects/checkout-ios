// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment

final public class BasicPaymentService: NSObject, PaymentService {
    static let supportedNetworkCodes = ["SEPADD", "PAYPAL", "WECHATPC-R"]
    static let supportedPaymentMethods: [PaymentMethod] = [.DEBIT_CARD, .CREDIT_CARD]

    private let supportedRedirectTypes = ["PROVIDER", "3DS2-HANDLER"]
    private let redirectController: RedirectController
    private let connection: Connection

    // MARK: - Static methods

    public static func isSupported(networkCode: String, paymentMethod: String?, providers: [String]?) -> Bool {
        if providers != nil && providers?.isEmpty == false {
            return false
        }

        if
            let methodString = paymentMethod,
            let method = PaymentMethod(rawValue: methodString),
            supportedPaymentMethods.contains(method)
        {
            return true
        }

        return supportedNetworkCodes.contains(networkCode)
    }

    // MARK: - Initializer

    public init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name) {
        self.connection = connection
        self.redirectController = RedirectController(openAppWithURLNotificationName: openAppWithURLNotificationName)
    }

    // MARK: - Send operation

    public func processPayment(operationRequest: OperationRequest, completion: @escaping PaymentService.CompletionBlock, presentationRequest: @escaping PaymentService.PresentationBlock) {
        let networkRequest: NetworkRequest.Operation
        do {
            networkRequest = try NetworkRequestBuilder().create(from: operationRequest)
        } catch {
            completion(.failure(error))
            return
        }

        let operation = SendRequestOperation(connection: connection, request: networkRequest)
        operation.downloadCompletionBlock = { [operationResponseHandler] result in
            operationResponseHandler(result, completion, presentationRequest)
        }
        operation.start()
    }

    private func operationResponseHandler(requestResult: Result<OperationResult, Error>, completion: @escaping PaymentService.CompletionBlock, presentationRequest: @escaping PaymentService.PresentationBlock) {
        switch requestResult {
        case .success(let operationResult):
            let redirectParser = RedirectResponseParser(supportedRedirectTypes: supportedRedirectTypes)
            let redirectURL: URL?
            do {
                redirectURL = try redirectParser.getRedirect(from: operationResult)
            } catch {
                completion(.failure(error))
                return
            }

            if let redirectURL = redirectURL {
                let viewControllerToPresent = redirectController.createSafariController(presentingURL: redirectURL) {
                    // Presentation completed, route the final result
                    switch $0 {
                    case .success(let operationResult):
                        completion(.success(operationResult))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                presentationRequest(viewControllerToPresent)
            } else {
                completion(.success(operationResult))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    // MARK: - Deletion

    public func delete(accountUsing accountURL: URL, completion: @escaping PaymentService.CompletionBlock) {
        let deletionRequest = NetworkRequest.DeleteAccount(url: accountURL)
        let operation = SendRequestOperation(connection: connection, request: deletionRequest)
        operation.downloadCompletionBlock = { result in
            switch result {
            case .success(let operationResult):
                completion(.success(operationResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        operation.start()
    }
}
