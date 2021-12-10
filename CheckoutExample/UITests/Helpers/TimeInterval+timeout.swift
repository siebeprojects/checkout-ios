// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

extension TimeInterval {
    static var networkTimeout: TimeInterval { return 30 }
    static var uiTimeout: TimeInterval { return 5 }
    static var safariPresentationTimeout: TimeInterval { return 10 }
}
