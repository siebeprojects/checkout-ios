// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking
@testable import Logging

private struct MockRequest: Request, Loggable {
    typealias Response = String

    let httpMethod: HTTPMethod
    let queryItems: [URLQueryItem]
    let url: URL

    func logRequest() {}
    func logResponse(_ response: String) {}
}

private struct VoidRequest: Request, Loggable {
    typealias Response = Void

    let httpMethod: HTTPMethod
    let queryItems: [URLQueryItem]
    let url: URL

    func logRequest() {}
    func logResponse(_ response: Void) {}
}

final class RequestTests: XCTestCase {
    func testDecodeResponse_whenDataIsNil_shouldThrowError() {
        let request = MockRequest(httpMethod: .GET, queryItems: [], url: URL(string: "/")!)
        XCTAssertThrowsError(try request.decodeResponse(with: nil))
    }

    func testDecodeResponse_whenDataIsValid_shouldReturnDecodedResponse() throws {
        let request = MockRequest(httpMethod: .GET, queryItems: [], url: URL(string: "/")!)
        let encoded = try JSONEncoder().encode("data")
        let decoded = try request.decodeResponse(with: encoded)
        XCTAssertEqual(decoded, "data")
    }

    func testDecodeResponse_whenDataIsVoid_shouldReturnVoid() throws {
        let request = VoidRequest(httpMethod: .GET, queryItems: [], url: URL(string: "/")!)
        let result: VoidRequest.Response = try request.decodeResponse(with: Data())
        XCTAssertTrue(result == Void())
    }

    func testBuild_shouldSetURLRequestHTTPMethod() throws {
        let request = MockRequest(httpMethod: .GET, queryItems: [], url: URL(string: "/")!)
        let urlRequest = try request.buildGenericRequest()
        XCTAssertEqual(urlRequest.httpMethod, request.httpMethod.rawValue)
    }

    func testBuild_shouldSetURLRequestURL() throws {
        let request = MockRequest(httpMethod: .GET, queryItems: [], url: URL(string: "/")!)
        let urlRequest = try request.buildGenericRequest()
        XCTAssertEqual(urlRequest.url, request.url)
    }

    func testBuild_whenQueryItems_shouldSetURLRequestQueryItems() throws {
        let request = MockRequest(httpMethod: .GET, queryItems: [URLQueryItem(name: "a", value: "a")], url: URL(string: "/")!)
        let urlRequest = try request.buildGenericRequest()

        XCTAssertEqual(urlRequest.url?.absoluteString, "\(request.url.absoluteString)?a=a")
    }
}
