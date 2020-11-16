// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class SelectOption: NSObject, Decodable {
    /// The value for this option.
    public let value: String

    /// If set to `true` this option should be pre-selected, otherwise no specific behavior should be applied for this option.
    public let selected: Bool?
}
