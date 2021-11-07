// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.Field {
    /// An identifier for input fields.
    ///
    /// It is used to have a clear identification of input field and to separate server models, ui models and payment request models that may seem that they used for the same entity but they're not.
    /// - Note: an identifier doesn't always equal server's model name (for the exception of `inputElementName` case).
    enum Identifier {
        /// The identifier for expiry date combined field's model (*mm / yy*)
        case expiryDate

        /// The identifier for registration switch or label
        case registration

        /// The identifier for recurrence switch or label
        case recurrence

        /// The identifier for combined registration and recurrence registration switch
        case combinedRegistration

        /// The identifier for field that uses server's `name` from input element
        case inputElementName(String)
    }
}

extension Input.Field.Identifier: Hashable {}