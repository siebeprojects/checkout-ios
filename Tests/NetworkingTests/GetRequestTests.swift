// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking
@testable import Logging

private struct MockRequest: GetRequest, Loggable {
    typealias Response = String

    let queryItems: [URLQueryItem]
    let url: URL

    func logRequest() {}
    func logResponse(_ response: String) {}
}

final class GetRequestTests: XCTestCase {
    func testHTTPMethod_shouldReturnGet() {
        let getRequest = MockRequest(queryItems: [], url: URL(string: "/")!)
        XCTAssertEqual(getRequest.httpMethod, .GET)
    }

    func testBuild_shouldSetURLRequestHTTPMethod() throws {
        let getRequest = MockRequest(queryItems: [], url: URL(string: "/")!)
        let urlRequest = try getRequest.build()
        XCTAssertEqual(urlRequest.httpMethod, getRequest.httpMethod.rawValue)
    }

    func testBuild_shouldSetURLRequestURL() throws {
        let getRequest = MockRequest(queryItems: [], url: URL(string: "/")!)
        let urlRequest = try getRequest.build()
        XCTAssertEqual(urlRequest.url, getRequest.url)
    }

    func testBuild_whenQueryItems_shouldSetURLRequestQueryItems() throws {
        let getRequest = MockRequest(queryItems: [URLQueryItem(name: "a", value: "a")], url: URL(string: "/")!)
        let urlRequest = try getRequest.build()

        XCTAssertEqual(urlRequest.url?.absoluteString, "\(getRequest.url.absoluteString)?a=a")
    }
}
