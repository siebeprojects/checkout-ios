// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout
import Risk

final class RiskProviderResponderTests: XCTestCase {
    /// Default value for `riskProvider` is `nil`, this test checks that it wasn't changed.
    func testNoRiskProviderInitializer() {
        let emptyResponder = RiskProviderDataCollector(code: "emptyRiskProviderResponder", type: "emptyRiskProviderResponderType")
        XCTAssertNil(emptyResponder.riskProvider)
    }

    // MARK: - Test `getProvidersParameters()`

    /// Tests for `ProviderParameters` if risk provider is `nil`.
    func testNoRiskProviderProviderParameters() {
        let emptyResponder = RiskProviderDataCollector(code: "emptyRiskProviderResponder", type: "emptyRiskProviderResponderType", riskProvider: nil)
        let providerParameters = emptyResponder.getProvidersParameters()

        XCTAssertEqual(providerParameters.providerCode, providerParameters.providerCode)
        XCTAssertEqual(providerParameters.providerType, providerParameters.providerType)
        XCTAssertTrue(providerParameters.parameters.isEmpty)
    }

    /// Test `ProviderParameters` when risk provider failed to collect risk data.
    func testRisksCollectionError() {
        let provider = TestRiskProvider(collectRiskDataBlock: {
            throw RiskProviderResponderError.riskDataCollectionFailed(underlyingError: "")
        })
        let responder = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = responder.getProvidersParameters()

        XCTAssertEqual(providerParameters.providerCode, TestRiskProvider.code)
        XCTAssertEqual(providerParameters.providerType, TestRiskProvider.type)
        XCTAssertTrue(providerParameters.parameters.isEmpty)
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
        let responder = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = responder.getProvidersParameters()

        XCTAssertEqual(providerParameters.providerCode, TestRiskProvider.code)
        XCTAssertEqual(providerParameters.providerType, TestRiskProvider.type)

        // Expected parameters have unordered dictionary type
        let expectedParameters = [
            Parameter(name: "blackbox", value: "blackbox 1"),
            Parameter(name: "blackbox2", value: "blackbox 2")
        ]

        XCTAssertEqual(providerParameters.parameters.count, 2)
        XCTAssertTrue(contains(parameter: expectedParameters[0], in: providerParameters.parameters))
        XCTAssertTrue(contains(parameter: expectedParameters[1], in: providerParameters.parameters))
    }

    private func contains(parameter: Parameter, in parameters: [Parameter]) -> Bool {
        return parameters.contains {
            $0.name == parameter.name && $0.value == parameter.value
        }
    }

    /// Test if provider collected risk data but provider shouldn't return anything.
    func testEmptyRisksData() {
        let provider = TestRiskProvider(collectRiskDataBlock: {
            return nil
        })
        let responder = RiskProviderDataCollector(riskProvider: provider)
        let providerParameters = responder.getProvidersParameters()

        XCTAssertTrue(providerParameters.parameters.isEmpty)
    }
}

private struct TestRiskProvider: RiskProvider {
    static var code: String { "testRiskProvider" }
    static var type: String? { "TEST_PROVIDER" }

    fileprivate var collectRiskDataBlock: (() throws -> [String : String?]?)?

    static func load(using parameters: [String : String?]) throws -> TestRiskProvider {
        return TestRiskProvider()
    }

    func collectRiskData() throws -> [String : String?]? {
        return try collectRiskDataBlock?()
    }
}
