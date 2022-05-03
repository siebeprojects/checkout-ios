// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking
import Payment
import BasicPaymentService

class PaymentServicesFactory {
    private let services: [PaymentService.Type]
    private let connection: Connection

    init(connection: Connection, services: [PaymentService.Type]) {
        self.connection = connection
        
        // `BasicPaymentService` should be always loaded by default
        self.services = services + [BasicPaymentService.self]
    }

    /// Lookup for appropriate payment service and create an instance if found
    func createPaymentService(forNetworkCode networkCode: String, paymentMethod: String?) -> PaymentService? {
        for service in services where service.isSupported(networkCode: networkCode, paymentMethod: paymentMethod) {
            return service.init(connection: connection, openAppWithURLNotificationName: .didReceiveCallbackFromURL)
        }

        return nil
    }

    func isSupported(networkCode: String, paymentMethod: String?) -> Bool {
        for service in services where service.isSupported(networkCode: networkCode, paymentMethod: paymentMethod) {
            return true
        }

        return false
    }
}
