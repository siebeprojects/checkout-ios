// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk

struct LoadSuccessDataCollectionFailRiskProvider: RiskProvider {
    static let code: String = "LoadSuccessDataCollectionFailRiskProvider"
    static let type: String? = "TEST_PROVIDER"

    static let dataCollectionError = RiskProviderError.externalFailure(
        reason: "reason",
        providerCode: code,
        providerType: type
    )

    static func load(withParameters parameters: [String: String?]) throws -> Self {
        return LoadSuccessDataCollectionFailRiskProvider()
    }

    func collectRiskData() throws -> [String: String?]? {
        throw LoadSuccessDataCollectionFailRiskProvider.dataCollectionError
    }
}
