// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk
import FraudForce

@objc final public class IovationRiskProvider: NSObject, RiskProvider {
    public static let code = "IOVATION"
    public static let type = "RISK_DATA_PROVIDER"

    private static var current: IovationRiskProvider?

    public static func load(withParameters parameters: [String: String?]) throws -> IovationRiskProvider {
        if let existingProvider = IovationRiskProvider.current {
            return existingProvider
        } else {
            let provider = IovationRiskProvider()
            IovationRiskProvider.current = provider
            FraudForce.start()
            return provider
        }
    }

    public func collectRiskData() throws -> [String: String?]? {
        return ["blackbox": FraudForce.blackbox()]
    }
}
