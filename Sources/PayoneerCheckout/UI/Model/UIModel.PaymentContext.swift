// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

extension UIModel {
    /// Global properties that may be useful but not directly related to applicable network or registered account.
    class PaymentContext {
        let listOperationType: UIModel.PaymentSession.Operation
        let extraElements: ExtraElements?
        let riskService: RiskService

        init(operationType: UIModel.PaymentSession.Operation, extraElements: ExtraElements?, riskService: RiskService) {
            self.listOperationType = operationType
            self.extraElements = extraElements
            self.riskService = riskService
        }
    }
}
