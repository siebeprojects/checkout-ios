// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Networking

final class ProviderParametersTests: XCTestCase {
    func testIsEqual_whenObjectIsNil_shouldReturnFalse() {
        let providerParameters = ProviderParameters(providerCode: "a", providerType: nil, parameters: nil)
        XCTAssertFalse(providerParameters.isEqual(nil))
    }

    func testIsEqual_whenProviderCodeIsEqual_whenProviderTypeIsEqual_whenParametersIsEqual_shouldReturnTrue() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        XCTAssertTrue(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsEqual_whenProviderTypeIsEqual_whenParametersIsDifferent_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "c", value: "d")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsEqual_whenProviderTypeIsDifferent_whenParametersIsEqual_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "a", providerType: "c", parameters: [Parameter(name: "a", value: "b")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsDifferent_whenProviderTypeIsEqual_whenParametersIsEqual_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "c", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsEqual_whenProviderTypeIsDifferent_whenParametersIsDifferent_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "a", providerType: "c", parameters: [Parameter(name: "c", value: "d")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsDifferent_whenProviderTypeIsEqual_whenParametersIsDifferent_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "c", providerType: "b", parameters: [Parameter(name: "c", value: "d")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsDifferent_whenProviderTypeIsDifferent_whenParametersIsEqual_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "c", providerType: "d", parameters: [Parameter(name: "a", value: "b")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }

    func testIsEqual_whenProviderCodeIsDifferent_whenProviderTypeIsDifferent_whenParametersIsDifferent_shouldReturnFalse() {
        let providerParameters1 = ProviderParameters(providerCode: "a", providerType: "b", parameters: [Parameter(name: "a", value: "b")])
        let providerParameters2 = ProviderParameters(providerCode: "c", providerType: "d", parameters: [Parameter(name: "c", value: "d")])
        XCTAssertFalse(providerParameters1.isEqual(providerParameters2))
    }
}
