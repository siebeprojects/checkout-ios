// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking
import Logging

private final class MockConnection: Connection {
    private(set) var sendCalled = false

    func send(request: URLRequest, completionHandler: @escaping ((Data?, Error?) -> Void)) {
        sendCalled = true
        completionHandler("{\"data\":\"data\"}".data(using: .utf8), nil)
    }

    static func isRecoverableError(_ error: Error) -> Bool {
        false
    }
}

private final class MockRequest: Request {
    typealias Response = [String: String]

    let httpMethod: HTTPMethod = .GET
    let queryItems: [URLQueryItem] = []
    let url: URL = URL(string: "/")!

    private(set) var buildCalled = false
    private(set) var logRequestCalled = false
    private(set) var logResponseCalled = false

    func build() throws -> URLRequest {
        buildCalled = true
        return URLRequest(url: URL(string: "/")!)
    }

    func logRequest() {
        logRequestCalled = true
    }

    func logResponse(_ response: [String: String]) {
        logResponseCalled = true
    }
}

extension MockRequest: Loggable {}

final class SendRequestOperationTests: XCTestCase {
    private var mockConnection: MockConnection!
    private var operation: SendRequestOperation<MockRequest>!

    override func setUp() {
        super.setUp()
        mockConnection = MockConnection()
        operation = SendRequestOperation(connection: mockConnection, request: MockRequest())
    }

    override func tearDown() {
        operation = nil
        mockConnection = nil
        super.tearDown()
    }

    func testMain_shouldCallRequestBuild() {
        operation.main()
        XCTAssertTrue(operation.request.buildCalled)
    }

    func testMain_shouldCallLogRequest() {
        operation.main()
        XCTAssertTrue(operation.request.logRequestCalled)
    }

    func testMain_shouldCallLogResponse() {
        operation.main()
        XCTAssertTrue(operation.request.logResponseCalled)
    }

    func testMain_shouldCallConnectionSend() {
        operation.main()
        XCTAssertTrue(mockConnection.sendCalled)
    }
}
