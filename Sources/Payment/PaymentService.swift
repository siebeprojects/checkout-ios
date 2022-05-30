// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import UIKit

@objc public protocol PaymentService: AnyObject {
    /// Returns whether the service can make payments
    static func isSupported(networkCode: String, paymentMethod: String?) -> Bool

    func processPayment(operationRequest: OperationRequest, completion: @escaping (OperationResult?, Error?) -> Void, presentationRequest: @escaping (UIViewController) -> Void)
    func delete(accountUsing accountURL: URL, completion: @escaping (OperationResult?, Error?) -> Void)

    init(connection: Connection, openAppWithURLNotificationName: NSNotification.Name)
}
