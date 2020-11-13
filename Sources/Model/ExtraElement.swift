// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class ExtraElement: NSObject, Decodable {
    /// Descriptive text that should be displayed for this extra element.
    public let text: String?

    /// Checkbox parameters, 'null' if this extra element is a label.
    public let checkbox: Checkbox?
}
