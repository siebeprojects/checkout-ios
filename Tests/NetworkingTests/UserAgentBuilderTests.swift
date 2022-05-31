// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

public class UserAgentBuilderTests: XCTestCase {
    private let builder = UserAgentBuilder()

    func testContainsVersionNumber() throws {
        let userAgentValue = builder.createUserAgentValue()
        let regex = #"IOSSDK\/\d\.\d\.\d\s"#
        let stringMatchesRegex = userAgentValue.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
        XCTAssert(stringMatchesRegex)
    }
}
