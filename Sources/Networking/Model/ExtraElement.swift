// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class ExtraElement: NSObject, Decodable {
    public let name: String
    public let label: String

    /// Checkbox parameters, 'null' if this extra element is a label.
    public let checkbox: Checkbox?
}
