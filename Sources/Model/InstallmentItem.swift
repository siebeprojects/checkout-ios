// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class InstallmentItem: NSObject, Decodable {
    /// An amount of this installment in major units.
    public let amount: Double?

    /// An installment (or payment) date.
    public let date: String?
}
