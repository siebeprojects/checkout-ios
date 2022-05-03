// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk
import FraudForce

@objc final public class IovationRiskProvider: NSObject, RiskProvider {
    public static let code: String = "IOVATION"
    public static let type: String? = "RISK_DATA_PROVIDER"

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
        let data = FraudForce.blackbox()

        guard data.isEmpty == false else {
            throw RiskProviderError.externalFailure(
                reason: "Empty blackbox received from Iovation risk provider. An empty blackbox indicates there is a problem with the integration of the SDK or that the protection offered by the system may have been compromised."
                providerCode: IovationRiskProvider.code,
                providerType: IovationRiskProvider.type
            )
        }

        return ["blackbox": data]
    }
}
