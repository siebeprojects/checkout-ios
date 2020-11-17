// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class ExtraElements: NSObject, Decodable {
    /// Collection of extra elements (labels and checkboxes) that should be displayed on the top of payment page.
    public let top: [ExtraElement]?

    /// Collection of extra elements (labels and checkboxes) that should be displayed on the bottom of payment page.
    public let bottom: [ExtraElement]?
}
