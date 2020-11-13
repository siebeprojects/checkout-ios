// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct ReplaceableString {
    var originText: String
    var changesRange: NSRange
    var replacementText: String
}
