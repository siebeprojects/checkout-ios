// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

final class ErrorInfoTests: XCTestCase {
    func testLocalizedDescription_shouldReturnResultInfo() {
        let errorInfo = ErrorInfo(resultInfo: "resultInfo", interaction: Interaction(code: "", reason: ""))
        XCTAssertEqual(errorInfo.localizedDescription, errorInfo.resultInfo)
    }
}
