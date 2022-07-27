// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

final class InteractionTests: XCTestCase {
    func testInit_shouldUseCodeRawValue() {
        let interaction = Interaction(code: .PROCEED, reason: .OK)
        XCTAssertEqual(interaction.code, Interaction.Code.PROCEED.rawValue)
    }

    func testInit_shouldUseReasonRawValue() {
        let interaction = Interaction(code: .PROCEED, reason: .OK)
        XCTAssertEqual(interaction.reason, Interaction.Reason.OK.rawValue)
    }
}
