// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout
import Risk
import Networking

final class RiskServiceTests: XCTestCase {
    /// Test risk service if provider failed to initialize
    func testRiskProviderFailedInit() throws {
        var riskService = RiskService(providers: [InitializationBrokenRiskProvider.self])
        let providerParameters = ProviderParameters(
                providerCode: InitializationBrokenRiskProvider.code,
                providerType: InitializationBrokenRiskProvider.type,
                parameters: [Parameter]()
        )
        riskService.loadRiskProviders(using: [providerParameters])

        try testNoRiskProviders(riskService: riskService)
    }

    /// Test risk service if provider wasn't found.
    func testProviderNotFound() throws {
        var service = RiskService(providers: [])
        let providerParameters = ProviderParameters(
            providerCode: InitializationBrokenRiskProvider.code,
            providerType: InitializationBrokenRiskProvider.type,
            parameters: [Parameter]()
        )
        service.loadRiskProviders(using: [providerParameters])

        try testNoRiskProviders(riskService: service)
    }

    /// Test if `RiskService` doesn't have any providers in responder.
    private func testNoRiskProviders(riskService: RiskService) throws {
        // Test responder
        XCTContext.runActivity(named: "Test responder") { activity in
            XCTAssertEqual(riskService.dataCollectors.count, 1, "Service should contain only one provider, even that provider failed to initialize or wasn't found")

            let responder = riskService.dataCollectors[0]
            activity.add(XCTAttachment(subject: responder))

            XCTAssertEqual(responder.code, InitializationBrokenRiskProvider.code)
            XCTAssertEqual(responder.type, InitializationBrokenRiskProvider.type)
            XCTAssertNil(responder.riskProvider, "Risk provider should be nil because it is failed to initialize or wasn't found")
        }

        // Test risk data
        try XCTContext.runActivity(named: "Test collected risk data") { activity in
            guard let riskData = riskService.collectRiskData() else {
                throw "Risk data shouldn't be nil"
            }

            activity.add(XCTAttachment(subject: riskData))

            XCTAssertEqual(riskData.count, 1, "Risk data should contain only one ProviderParameters, even provider failed to initialize or wasn't found")
            XCTAssertEqual(riskData[0].providerCode, InitializationBrokenRiskProvider.code)
            XCTAssertEqual(riskData[0].providerType, InitializationBrokenRiskProvider.type)
            XCTAssertTrue(riskData[0].parameters!.isEmpty, "Risk data should be empty because risk provider was failed to initialize or wasn't found")
        }
    }

    /// Test if risk provider successfully initialized.
    func testSuccessfullRiskProvider() throws {
        var service = RiskService(providers: [WorkingRiskProvider.self])
        let providerParameters = ProviderParameters(
            providerCode: WorkingRiskProvider.code,
            providerType: WorkingRiskProvider.type,
            parameters: []
        )
        service.loadRiskProviders(using: [providerParameters])

        XCTContext.runActivity(named: "Test responder") { activity in
            XCTAssertEqual(service.dataCollectors.count, 1)

            let responder = service.dataCollectors[0]
            activity.add(XCTAttachment(subject: responder))

            XCTAssertEqual(responder.code, providerParameters.providerCode)
            XCTAssertEqual(responder.type, providerParameters.providerType)
            XCTAssertNotNil(responder.riskProvider)
        }

        // Test risk data
        try XCTContext.runActivity(named: "Test collected risk data") { activity in
            guard let riskData = service.collectRiskData() else {
                throw "Risk data shouldn't be nil"
            }

            activity.add(XCTAttachment(subject: riskData))

            // Test risk data
            XCTAssertEqual(riskData.count, 1)
            XCTAssertEqual(riskData[0].providerCode, providerParameters.providerCode)
            XCTAssertEqual(riskData[0].providerType, providerParameters.providerType)

            // Test parameter
            XCTAssertEqual(riskData[0].parameters?.count, 1, "Risk data should contain only one parameter")
            XCTAssertEqual(riskData[0].parameters?[0].name, WorkingRiskProvider.riskData.first!.key)
            XCTAssertEqual(riskData[0].parameters?[0].value, WorkingRiskProvider.riskData.first!.value)
        }
    }
}

private struct InitializationBrokenRiskProvider: RiskProvider {
    static var code: String { "InitializationFailedRiskProvider" }
    static var type: String? { "TEST_PROVIDER" }

    static var initializationError: Error { "Initialization failed" }

    static func load(using parameters: [String : String?]) throws -> Self {
        throw initializationError
    }

    func collectRiskData() throws -> [String : String?]? {
        return nil
    }
}

private struct WorkingRiskProvider: RiskProvider {
    static var code: String { "WorkingRiskProvider" }
    static var type: String? { "TEST_PROVIDER" }

    static var riskData: [String: String?] { ["testKey": "testValue"] }

    static func load(using parameters: [String : String?]) throws -> Self {
        return .init()
    }

    func collectRiskData() throws -> [String : String?]? {
        return WorkingRiskProvider.riskData
    }
}
