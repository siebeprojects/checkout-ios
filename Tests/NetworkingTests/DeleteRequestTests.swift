// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking
@testable import Logging

private struct MockRequest: DeleteRequest, Loggable {
    var body: String?

    typealias Body = String
    typealias Response = String

    let queryItems: [URLQueryItem]
    let url: URL

    func logRequest() {}
    func logResponse(_ response: String) {}
}

final class DeleteRequestTests: XCTestCase {
    func testHTTPMethod_shouldReturnDelete() {
        let deleteRequest = MockRequest(queryItems: [], url: URL(string: "/")!)
        XCTAssertEqual(deleteRequest.httpMethod, .DELETE)
    }
}
