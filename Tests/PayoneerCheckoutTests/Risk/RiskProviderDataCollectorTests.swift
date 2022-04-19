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
        let provider = TestRiskProvider(error: RiskProviderDataCollectorError.riskDataCollectionFailed(underlyingError: ""))
        let dataCollector = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = dataCollector.getProviderParameters()

        XCTAssertEqual(providerParameters.providerCode, TestRiskProvider.code)
        XCTAssertEqual(providerParameters.providerType, TestRiskProvider.type)
        XCTAssertTrue(providerParameters.parameters!.isEmpty)
    }

    /// Test when risk data was successfully collected by provider.
    func testSuccessfulRiskCollection() {
        let provider = TestRiskProvider(data: [
            // Return ordered dictionary
            "blackbox": "blackbox 1",
            "blackbox2": "blackbox 2"
        ])
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

    func testRiskProvider_whenDataIsEmpty_shouldThrowExternalError() {
        let provider = TestRiskProvider(data: [:])

        XCTAssertThrowsError(try provider.collectRiskData()) { error in
            XCTAssertEqual(error as? RiskProviderError, RiskProviderError.externalFailure(reason: ""))
        }
    }
}

private struct TestRiskProvider: RiskProvider {
    static let code: String = "testRiskProvider"
    static let type: String? = "TEST_PROVIDER"

    fileprivate var data: [String: String?]?
    fileprivate var error: Error?

    static func load(withParameters parameters: [String: String?]) throws -> TestRiskProvider {
        return TestRiskProvider()
    }

    func collectRiskData() throws -> [String: String?]? {
        if let error = error {
            throw error
        }

        guard data?.isEmpty == false else {
            throw RiskProviderError.externalFailure(reason: "Data collection failed")
        }

        return data
    }
}
