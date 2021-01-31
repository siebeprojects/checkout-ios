// Copyright (c) 2020–2021 Payoneer Germany GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

extension XCTAttachment {
    convenience init<T>(subject: T) {
        var text = String()
        dump(subject, to: &text)
        self.init(string: text)
    }
}
