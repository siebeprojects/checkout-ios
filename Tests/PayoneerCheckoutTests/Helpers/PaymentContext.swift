// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Risk
@testable import PayoneerCheckout
import Networking

extension UIModel.PaymentContext {
    /// Init with empty risk service
    convenience init(operationType: UIModel.PaymentSession.Operation, extraElements: ExtraElements?) {
        let registry = RiskProviderRegistry()
        let riskService = RiskService(registry: registry)
        self.init(operationType: operationType, extraElements: extraElements, riskService: riskService)
    }
}
