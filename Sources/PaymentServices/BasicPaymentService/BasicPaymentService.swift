// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import Payment
import UIKit

@objc public class BasicPaymentService: NSObject, PaymentService {
    // MARK: - Static methods
    public static func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        if let methodString = paymentMethod, let method = PaymentMethod(rawValue: methodString) {
            let supportedMethods: [PaymentMethod] = [.DEBIT_CARD, .CREDIT_CARD]
            return supportedMethods.contains(method)
        } else {
            let supportedCodes = ["SEPADD", "PAYPAL", "WECHATPC-R"]
            return supportedCodes.contains(networkCode)
        }
    }

    // MARK: -
    let connection: Connection

    required public init(connection: Connection) {
        self.connection = connection
    }

    public func send(operationRequest: OperationRequest, completion: @escaping (OperationResult?, Error?) -> Void, presentationRequest: (UIViewController) -> Void) {
        let networkRequest: NetworkRequest.Operation
        do {
            networkRequest = try NetworkRequestBuilder().create(from: operationRequest)
        } catch {
            completion(nil, error)
            return
        }

        let operation = SendRequestOperation(connection: connection, request: networkRequest)
        operation.downloadCompletionBlock = { result in
            switch result {
            case .success(let operationResult): completion(operationResult, nil)
            case .failure(let error): completion(nil, error)
            }
        }
        operation.start()
    }

    public func delete(accountUsing accountURL: URL, completion: @escaping (OperationResult?, Error?) -> Void, presentationRequest: (UIViewController) -> Void) {
        let deletionRequest = NetworkRequest.DeleteAccount(url: accountURL)
        let operation = SendRequestOperation(connection: connection, request: deletionRequest)
        operation.downloadCompletionBlock = { result in
            switch result {
            case .success(let operationResult): completion(operationResult, nil)
            case .failure(let error): completion(nil, error)
            }
        }
        operation.start()
    }
}

