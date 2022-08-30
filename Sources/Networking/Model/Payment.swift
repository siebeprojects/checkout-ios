// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public final class Payment: Decodable {
    /// A short description of the order given by merchant; will appear on bank statements or invoices for the customer if possible
    public let reference: String

    /// The total amount (including taxes, shipping, etc.) of this order in native format using "." as decimal delimiter; this amount will be collected from the customer.
    public let amount: Double

    /// Currency of this payment; format according to ISO-4217 form, e.g. "EUR", "USD"
    public let currency: String

    /// Invoice ID assigned by merchant to this payment
    public let invoiceId: String?

    /// Payment deadline (time window a customer should complete a payment)
    public let dueDate: Date?

    /// Possible payment types
    ///
    /// * `UNSCHEDULED` - use for the one-off recurring transaction.
    /// * `SCHEDULED` - use for the scheduled recurring transaction.
    public let type: String?
}
