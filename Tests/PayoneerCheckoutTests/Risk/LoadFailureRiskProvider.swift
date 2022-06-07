// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk

struct LoadFailureRiskProvider: RiskProvider {
    static let code: String = "LoadFailureRiskProvider"
    static let type: String? = "TEST_PROVIDER"

    static func load(withParameters parameters: [String: String?]) throws -> Self {
        throw RiskProviderError.externalFailure(reason: "", providerCode: code, providerType: type)
    }

    func collectRiskData() throws -> [String: String?]? {
        return nil
    }
}
