// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public enum RiskProviderError: Error {
    case internalFailure(reason: String)
    case externalFailure(reason: String)

    public var name: String {
        switch self {
        case .internalFailure:
            return "riskProviderInternalError"
        case .externalFailure:
            return "riskProviderExternalError"
        }
    }

    public var reason: String {
        switch self {
        case .internalFailure(let reason), .externalFailure(let reason):
            return String(reason.prefix(2000))
        }
    }
}

// MARK: - Equatable

extension RiskProviderError: Equatable {
    public static func == (lhs: RiskProviderError, rhs: RiskProviderError) -> Bool {
        switch (lhs, rhs) {
        case (.internalFailure, .internalFailure), (.externalFailure, .externalFailure):
            return true
        case (.internalFailure, .externalFailure), (.externalFailure, .internalFailure):
            return false
        }
    }
}
