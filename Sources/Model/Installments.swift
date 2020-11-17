// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class Installments: NSObject, Decodable {
    /// An information about original payment
    public let originalPayment: PaymentAmount?

    /// Collection of calculated installments plans what should be present to customer.
    public let plans: [InstallmentsPlan]?
}
