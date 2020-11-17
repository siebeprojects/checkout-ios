// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class PaymentAmount: NSObject, Decodable {
    /// Payment amount in major units.
    public let amount: Double

    /// 3-letter currency code (ISO 4217)
    public let currency: String
}
