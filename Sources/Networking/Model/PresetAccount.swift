// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class PresetAccount: NSObject, Decodable {
    /// Collection of links related to this `PRESET` account.
    public let links: [String: URL]

    /// Code of preset network
    public let code: String

    /// Masked account of preset account; sensitive fields of the account are removed, truncated, or replaced with mask characters.
    public let maskedAccount: AccountMask?

    /// Indicates that form for this account is empty, without any text and input elements.
    public let emptyForm: Bool

    /// Code of button-label for this preset account.
    /// - WARNING: Out of sync with optile.io's [documentation](https://www.optile.io/reference#operation/getPaymentSession).
    public let button: String?

    /// Redirect object to summary page of merchants web-site.
    public let redirect: Redirect

    /// Type of operation
    public let operationType: String

    /// Indicates payment method this preset account belongs to.
    public let method: String

    /// The deferred behavior of the payment network. See [Deferred Payments](https://www.optile.io/opg#285066) for more details.
    public let deferral: String?

    /// Map of public available contract data from the first possible route for this preset account.
//    let contractData: String?

    /// Indicates whether this preset account is based on already registered network or not
    public let registered: Bool?

    /// Indicates the end-customer choice for storing his payment method
    public let autoRegistration: Bool?

    /// Indicates the end-customer choice for storing his payment method for recurring charges
    public let allowRecurrence: Bool?
}
