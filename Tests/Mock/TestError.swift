// Copyright (c) 2020–2021 Payoneer Germany GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct TestError: Error, CustomDebugStringConvertible {
    var debugDescription: String

    init(description: String) {
        self.debugDescription = description
    }
}
