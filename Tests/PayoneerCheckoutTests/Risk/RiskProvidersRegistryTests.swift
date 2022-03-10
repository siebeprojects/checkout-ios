// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
import PayoneerCheckout
import Risk

class RiskProvidersRegistryTests: XCTestCase {
    func testRegistration() {
        let registry = RiskProviderRegistry()
        XCTAssertTrue(registry.registeredProviders.isEmpty)

        registry.register(provider: TestRiskProvider.self)
        XCTAssertTrue(registry.registeredProviders.first is TestRiskProvider.Type)
        XCTAssertEqual(registry.registeredProviders.count, 1)
    }
}

private struct TestRiskProvider: RiskProvider {
    static var code: String { "TestProvider" }
    static var type: String? { "TEST_PROVIDER" }

    static func load(using parameters: [String : String?]) throws -> Self {
        return TestRiskProvider()
    }

    func collectRiskData() throws -> [String : String?]? {
        return nil
    }
}
