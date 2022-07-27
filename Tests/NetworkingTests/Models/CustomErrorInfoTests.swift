// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

private struct TestError: Error {}

final class CustomErrorInfoTests: XCTestCase {
    func testInit_shouldSetUnderlyingError() {
        let errorInfo = CustomErrorInfo(resultInfo: "", interaction: Interaction(code: .PROCEED, reason: .OK), underlyingError: TestError())
        XCTAssertNotNil(errorInfo.underlyingError)
    }

    func testInitFromDecoder_shouldThrowError() {
        XCTAssertThrowsError(try JSONDecoder().decode(CustomErrorInfo.self, from: "{}".data(using: .utf8)!))
    }

    func testCreateClientSideError_shouldSetInteractionCodeToABORT() {
        let errorInfo = CustomErrorInfo.createClientSideError(from: TestError())
        XCTAssertEqual(errorInfo.interaction.code, Interaction.Code.ABORT.rawValue)
    }

    func testCreateClientSideError_shouldSetInteractionReasonToCLIENTSIDEERROR() {
        let errorInfo = CustomErrorInfo.createClientSideError(from: TestError())
        XCTAssertEqual(errorInfo.interaction.reason, Interaction.Reason.CLIENTSIDE_ERROR.rawValue)
    }
}
