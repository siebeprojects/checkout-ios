// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class Checkbox: NSObject, Decodable {
    /// Operating and display mode of this checkbox.
    public let mode: String

    /// Error message that will be displayed if checkbox is required, but was not checked.
    public let requiredMessage: String?

    // MARK: - Enumerations

    public var checkboxMode: Mode? { Mode(rawValue: mode) }

    public enum Mode: String, Decodable {
        case OPTIONAL, OPTIONAL_PRESELECTED, REQUIRED, REQUIRED_PRESELECTED, FORCED, FORCED_DISPLAYED
    }
}
