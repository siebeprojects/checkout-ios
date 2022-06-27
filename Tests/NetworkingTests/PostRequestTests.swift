// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking
@testable import Logging

private final class MockRequest: PostRequest, Loggable {
    var body: String?

    typealias Body = String
    typealias Response = String

    let queryItems: [URLQueryItem]
    let url: URL

    init(queryItems: [URLQueryItem], url: URL) {
        self.queryItems = queryItems
        self.url = url
    }

    func logRequest() {}
    func logResponse(_ response: String) {}
}

final class PostRequestTests: XCTestCase {
    func testHTTPMethod_shouldReturnPost() {
        let postRequest = MockRequest(queryItems: [], url: URL(string: "/")!)
        XCTAssertEqual(postRequest.httpMethod, .POST)
    }
}
