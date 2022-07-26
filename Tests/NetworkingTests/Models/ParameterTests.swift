// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

final class ParameterTests: XCTestCase {
    func testIsEqual_whenObjectIsNil_shouldReturnFalse() {
        let parameter = Parameter(name: "", value: nil)
        XCTAssertFalse(parameter.isEqual(nil))
    }

    func testIsEqual_whenNameIsEqual_whenValueIsEqual_shouldReturnTrue() {
        let parameter1 = Parameter(name: "a", value: "b")
        let parameter2 = Parameter(name: "a", value: "b")
        XCTAssertTrue(parameter1.isEqual(parameter2))
    }

    func testIsEqual_whenNameIsEqual_whenValueIsDifferent_shouldReturnFalse() {
        let parameter1 = Parameter(name: "a", value: "b")
        let parameter2 = Parameter(name: "a", value: "c")
        XCTAssertFalse(parameter1.isEqual(parameter2))
    }

    func testIsEqual_whenNameIsDifferent_whenValueIsEqual_shouldReturnFalse() {
        let parameter1 = Parameter(name: "a", value: "b")
        let parameter2 = Parameter(name: "c", value: "b")
        XCTAssertFalse(parameter1.isEqual(parameter2))
    }

    func testIsEqual_whenNameIsDifferent_whenValueIsDifferent_shouldReturnFalse() {
        let parameter1 = Parameter(name: "a", value: "b")
        let parameter2 = Parameter(name: "c", value: "d")
        XCTAssertFalse(parameter1.isEqual(parameter2))
    }

    func testSubscript_whenKeyIsInvalid_shouldReturnNil() {
        let parameters = [Parameter(name: "a", value: "b")]
        XCTAssertNil(parameters["x"])
    }

    func testSubscript_whenKeyIsValid_shouldReturnValue() {
        let parameters = [
            Parameter(name: "a", value: "b"),
            Parameter(name: "c", value: "d")
        ]

        XCTAssertEqual(parameters["c"], "d")
    }
}
