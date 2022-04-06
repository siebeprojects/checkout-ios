// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk
import FraudForce

@objc final public class IovationRiskProvider: NSObject, RiskProvider {
    public static var code: String { "IOVATION" }
    public static var type: String? { "RISK_DATA_PROVIDER" }

    private static var shared: IovationRiskProvider?

    public static func load(using parameters: [String: String?]) throws -> IovationRiskProvider {
        if let existingProvider = IovationRiskProvider.shared {
            return existingProvider
        } else {
            let provider = IovationRiskProvider()
            IovationRiskProvider.shared = provider
            FraudForce.start()
            return provider
        }
    }

    public func collectRiskData() throws -> [String: String?]? {
        return ["blackbox": FraudForce.blackbox()]
    }
}
