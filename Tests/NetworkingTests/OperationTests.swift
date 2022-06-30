// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

final class OperationTests: XCTestCase {
    func testInit_shouldSetQueryItems() {
        let operation = NetworkRequest.Operation(from: URL(string: "/")!, account: nil, autoRegistration: nil, allowRecurrence: nil, providerRequest: nil, providerRequests: nil)
        XCTAssertTrue(operation.queryItems.isEmpty)
    }

    func testInit_shouldSetBodyBrowserData() {
        let operation = NetworkRequest.Operation(from: URL(string: "/")!, account: nil, autoRegistration: nil, allowRecurrence: nil, providerRequest: nil, providerRequests: nil)
        XCTAssertEqual(operation.body?.browserData, BrowserDataBuilder.build())
    }
}
