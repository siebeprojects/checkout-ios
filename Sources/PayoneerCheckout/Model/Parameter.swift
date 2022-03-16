// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class Parameter: NSObject, Codable {
    /// Parameter name.
    public let name: String

    /// Parameter value.
    public let value: String?

    internal init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}

extension Sequence where Element == Parameter {
    /// Returns a value for parameter with specified name
    subscript(name: String) -> String? {
        return first(where: { $0.name == name })?.value
    }
}
