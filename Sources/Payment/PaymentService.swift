// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import UIKit

public protocol PaymentService: AnyObject {
    typealias CompletionBlock = (OperationResult?, Error?) -> Void
    typealias PresentationBlock = (UIViewController) -> Void

    /// Returns whether the service can make payments
    static func isSupported(networkCode: String, paymentMethod: String?, providers: [String]?) -> Bool

    func processPayment(operationRequest: OperationRequest, completion: @escaping CompletionBlock, presentationRequest: @escaping PresentationBlock)
    func delete(accountUsing accountURL: URL, completion: @escaping CompletionBlock)

    init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name)
}
