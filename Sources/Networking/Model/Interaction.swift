// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

open class Interaction: NSObject, Decodable {
    public enum Code: String, Decodable {
        case PROCEED
        case ABORT
        case TRY_OTHER_NETWORK
        case TRY_OTHER_ACCOUNT
        case RETRY
        case RELOAD
        case VERIFY
    }

    public enum Reason: String, Decodable {
        case OK
        case PENDING
        case TRUSTED
        case STRONG_AUTHENTICATION
        case DECLINED
        case EXPIRED
        case EXCEEDS_LIMIT
        case TEMPORARY_FAILURE
        case UNKNOWN
        case NETWORK_FAILURE
        // swiftlint:disable:next inclusive_language
        case BLACKLISTED
        case BLOCKED
        case SYSTEM_FAILURE
        case INVALID_ACCOUNT
        case FRAUD
        case ADDITIONAL_NETWORKS
        case INVALID_REQUEST
        case SCHEDULED
        case NO_NETWORKS
        case DUPLICATE_OPERATION
        case CHARGEBACK
        case RISK_DETECTED
        case CUSTOMER_ABORT
        case EXPIRED_SESSION
        case EXPIRED_ACCOUNT
        case ACCOUNT_NOT_ACTIVATED
        case TRUSTED_CUSTOMER
        case UNKNOWN_CUSTOMER
        case ACTIVATED
        case UPDATED
        case TAKE_ACTION
        case COMMUNICATION_FAILURE
        case CLIENTSIDE_ERROR
    }

    /// Interaction code that advices further interaction with this customer or payment.
    /// See list of [Interaction Codes](https://www.optile.io/opg#292619).
    public let code: String

    /// Reason of this interaction, complements interaction code and has more detailed granularity.
    /// See list of [Interaction Codes](https://www.optile.io/opg#292619).
    public let reason: String

    public init(code: Code, reason: Reason) {
        self.code = code.rawValue
        self.reason = reason.rawValue
    }

    public init(code: String, reason: String) {
        self.code = code
        self.reason = reason
    }
}
