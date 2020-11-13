// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class FormData: NSObject, Decodable {
    /// Account related data to pre-fill a form.
    public let account: AccountFormData?

    /// Customer related data to pre-fill a form.
    public let customer: CustomerFormData?

    /// Data about possible installments plans.
    public let installments: Installments?

    /// URL to the data privacy consent document.
    public let dataPrivacyConsentUrl: URL?
}
