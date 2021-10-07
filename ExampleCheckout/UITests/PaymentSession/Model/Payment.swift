// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Payment information.
struct Payment: Codable {
    /// Short description of the order given by merchant. This will appear on bank statements or invoices of customer account if supported by PSP and selected payment method.
    let reference: String

    /// The total amount (including taxes, shipping, etc.) of this order in native format using "." as decimal delimiter. Customer will be charged for this amount.
    let amount: Double

    /// Currency of this payment. Value format is according to ISO-4217 form, e.g. "EUR", "USD".
    let currency: String
}
