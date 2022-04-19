// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout
import Risk

final class RiskProviderDataCollectorTests: XCTestCase {
    /// Default value for `riskProvider` is `nil`, this test checks that it wasn't changed.
    func testNoRiskProviderInitializer() {
        let emptyDataCollector = RiskProviderDataCollector(code: "emptyCode", type: "emptyType")
        XCTAssertNil(emptyDataCollector.riskProvider)
    }

    // MARK: - Test `getProviderParameters()`

    /// Tests for `ProviderParameters` if risk provider is `nil`.
    func testNoRiskProviderProviderParameters() {
        let emptyDataCollector = RiskProviderDataCollector(code: "emptyCode", type: "emptyType", riskProvider: nil)
        let providerParameters = emptyDataCollector.getProviderParameters()

        XCTAssertEqual(providerParameters.providerCode, providerParameters.providerCode)
        XCTAssertEqual(providerParameters.providerType, providerParameters.providerType)
        XCTAssertTrue(providerParameters.parameters!.isEmpty)
    }

    /// Test `ProviderParameters` when risk provider failed to collect risk data.
    func testRisksCollectionError() {
        let provider = TestRiskProvider(collectRiskDataBlock: {
            throw RiskProviderDataCollectorError.riskDataCollectionFailed(underlyingError: "")
        })
        let dataCollector = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = dataCollector.getProviderParameters()

        XCTAssertEqual(providerParameters.providerCode, TestRiskProvider.code)
        XCTAssertEqual(providerParameters.providerType, TestRiskProvider.type)
        XCTAssertTrue(providerParameters.parameters!.isEmpty)
    }

    /// Test when risk data was successfully collected by provider.
    func testSuccessfulRiskCollection() {
        let provider = TestRiskProvider(collectRiskDataBlock: {
            // Return ordered dictionary
            return [
                "blackbox": "blackbox 1",
                "blackbox2": "blackbox 2"
            ]
        })
        let dataCollector = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = dataCollector.getProviderParameters()

        XCTAssertEqual(providerParameters.providerCode, TestRiskProvider.code)
        XCTAssertEqual(providerParameters.providerType, TestRiskProvider.type)

        // Expected parameters have unordered dictionary type
        let expectedParameters = [
            Parameter(name: "blackbox", value: "blackbox 1"),
            Parameter(name: "blackbox2", value: "blackbox 2")
        ]

        XCTAssertEqual(providerParameters.parameters?.count, 2)
        XCTAssertTrue(providerParameters.parameters!.contains(expectedParameters[0]))
        XCTAssertTrue(providerParameters.parameters!.contains(expectedParameters[1]))
    }

    /// Test if provider collected risk data but provider shouldn't return anything.
    func testEmptyRisksData() {
        let provider = TestRiskProvider(collectRiskDataBlock: {
            return nil
        })
        let dataCollector = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = dataCollector.getProviderParameters()

        XCTAssertTrue(providerParameters.parameters!.isEmpty)
    }
}

private struct TestRiskProvider: RiskProvider {
    static var code: String { "testRiskProvider" }
    static var type: String? { "TEST_PROVIDER" }

    fileprivate var collectRiskDataBlock: (() throws -> [String : String?]?)?

    static func load(withParameters parameters: [String : String?]) throws -> TestRiskProvider {
        return TestRiskProvider()
    }

    func collectRiskData() throws -> [String : String?]? {
        return try collectRiskDataBlock?()
    }
}
