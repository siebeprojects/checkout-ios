// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

private struct MockEncodable: BodyEncodable {
    let body: String?
}

final class BodyEncodableTests: XCTestCase {
    func testEncodeBody_whenBodyIsNil_shouldReturnNil() throws {
        let mock = MockEncodable(body: nil)
        XCTAssertNil(try mock.encodeBody())
    }

    func testEncodeBody_whenBodyIsEmpty_shouldReturnEmptyJSON() throws {
        let mock = MockEncodable(body: "")
        XCTAssertEqual(try mock.encodeBody(), try JSONEncoder().encode(Data()))
    }

    func testEncodeBody_whenBodyIsValid_shouldReturnEncodedBody() throws {
        let body = "body"
        let mock = MockEncodable(body: body)
        let encodedData = try mock.encodeBody()
        XCTAssertEqual(try JSONDecoder().decode(String.self, from: encodedData!), body)
    }
}
