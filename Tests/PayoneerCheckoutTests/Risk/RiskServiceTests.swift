// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout
import Risk

final class RiskServiceTests: XCTestCase {
    func testLoadRiskProviders_whenLoadFails_shouldStoreExternalError() {
        var service = RiskService(providers: [LoadFailureRiskProvider.self])

        let providerParameters = ProviderParameters(
            providerCode: LoadFailureRiskProvider.code,
            providerType: LoadFailureRiskProvider.type,
            parameters: []
        )

        service.loadRiskProviders(withParameters: [providerParameters])

        XCTAssertEqual(service.loadedProviders.count, 0)
        XCTAssertEqual(service.providerErrors.count, 1)
        XCTAssertEqual(service.providerErrors.first, .externalFailure(reason: "", providerCode: "", providerType: ""))
    }

    func testLoadRiskProviders_whenProviderNotFound_shouldStoreInternalError() {
        var service = RiskService(providers: [])

        let providerParameters = ProviderParameters(
            providerCode: LoadFailureRiskProvider.code,
            providerType: LoadFailureRiskProvider.type,
            parameters: []
        )

        service.loadRiskProviders(withParameters: [providerParameters])

        XCTAssertEqual(service.loadedProviders.count, 0)
        XCTAssertEqual(service.providerErrors.count, 1)
        XCTAssertEqual(service.providerErrors.first, .internalFailure(reason: "", providerCode: "", providerType: ""))
    }

    func testLoadRiskProviders_whenLoadSucceeds_shouldStoreLoadedProvider() {
        let providerType = LoadSuccessRiskProvider.self

        var service = RiskService(providers: [providerType])

        let providerParameters = ProviderParameters(
            providerCode: providerType.code,
            providerType: providerType.type,
            parameters: []
        )

        service.loadRiskProviders(withParameters: [providerParameters])

        XCTAssertEqual(service.loadedProviders.count, 1)
        XCTAssertEqual(service.providerErrors.count, 0)
        XCTAssertTrue(service.loadedProviders.first is LoadSuccessRiskProvider)
    }

    func testCollectRiskData_whenLoadFails_shouldReturnEmpty() {
        var service = RiskService(providers: [])

        service.loadRiskProviders(withParameters: [])

        XCTAssertTrue(service.collectRiskData().isEmpty)
    }

    func testCollectRiskData_whenLoadSucceeds_whenDataCollectionSucceeds_shouldReturnRiskDataParameters() {
        let providerType = LoadSuccessRiskProvider.self

        var service = RiskService(providers: [providerType])

        let providerParameters = ProviderParameters(
            providerCode: providerType.code,
            providerType: providerType.type,
            parameters: []
        )

        service.loadRiskProviders(withParameters: [providerParameters])

        let data = service.collectRiskData()

        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(
            data.first,
            ProviderParameters(
                providerCode: providerType.code,
                providerType: providerType.type,
                parameters: [Parameter(name: "key", value: "value")]
            )
        )
    }

    func testCollectRiskData_whenLoadSucceeds_whenDataCollectionFails_shouldReturnErrorParameters() {
        let providerType = LoadSuccessDataCollectionFailRiskProvider.self

        var service = RiskService(providers: [providerType])

        let providerParameters = ProviderParameters(
            providerCode: providerType.code,
            providerType: providerType.type,
            parameters: []
        )

        service.loadRiskProviders(withParameters: [providerParameters])

        let data = service.collectRiskData()

        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(
            data.first,
            ProviderParameters(
                providerCode: providerType.code,
                providerType: providerType.type,
                parameters: [
                    Parameter(
                        name: providerType.dataCollectionError.name,
                        value: providerType.dataCollectionError.reason
                    )
                ]
            )
        )
    }
}
