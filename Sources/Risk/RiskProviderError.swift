// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

// Defined in https://optile.atlassian.net/browse/PCX-2999
private let errorStringMaximumLength = 2000

public enum RiskProviderError: Error, Equatable {
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
            return String(reason.prefix(errorStringMaximumLength))
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
