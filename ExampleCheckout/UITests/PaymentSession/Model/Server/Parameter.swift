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

    public init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}

// MARK: - Equatable

extension Parameter {
    public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
        lhs.name == rhs.name && lhs.value == rhs.value
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let parameter = object as? Parameter else { return false }
        return self == parameter
    }
}

extension Sequence where Element == Parameter {
    /// Returns a value for parameter with specified name
    public subscript(name: String) -> String? {
        return first(where: { $0.name == name })?.value
    }
}
