// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class Parameter: NSObject, Decodable {
    /// Parameter name.
    public let name: String

    /// Parameter value.
    public let value: String?

    internal init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}
