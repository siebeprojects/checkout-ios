// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public enum RiskProviderError: Error {
    case internalFailure(reason: String, providerCode: String, providerType: String?)
    case externalFailure(reason: String, providerCode: String, providerType: String?)

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
        case .internalFailure(let reason, _, _), .externalFailure(let reason, _, _):
            return String(reason.prefix(2000))
        }
    }

    public var providerCode: String {
        switch self {
        case .internalFailure(_, let providerCode, _), .externalFailure(_, let providerCode, _):
            return providerCode
        }
    }

    public var providerType: String? {
        switch self {
        case .internalFailure(_, _, let providerType), .externalFailure(_, _, let providerType):
            return providerType
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
