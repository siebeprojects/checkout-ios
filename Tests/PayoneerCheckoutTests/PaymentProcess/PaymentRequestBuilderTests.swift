// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout
import Networking
import Payment

final class PaymentRequestBuilderTests: XCTestCase {
    func testExtraElements() throws {
        // Here we create a model ready to be sent to a server (`OperationRequest`)
        // ListResult -> UIModel -> ... (filled with empty values) -> OperationRequest
        let operationRequest: OperationRequest = try {
            let dummyRiskService = RiskService(providers: [])
            let inputNetwork = try InputNetworkFactory.createInputNetworkWithExtraElements()
            let builder = PaymentRequestBuilder(riskService: dummyRiskService)

            return try builder.createPaymentRequest(for: inputNetwork)
        }()

        // Checkboxes models that should be built from extra elements
        let checkboxes = operationRequest.form?.checkboxes

        // We didn't change any values in extra elements so final model should contain default values.
        // Model could contain practically impossible values because of validation rules, but we don't run client-side validation here.

        XCTContext.runActivity(named: "Test top extra elements") { _ in
            XCTAssertEqual(checkboxes?["TOP_OPTIONAL"], false)
            XCTAssertEqual(checkboxes?["TOP_OPTIONAL_PRESELECTED"], true)
            XCTAssertEqual(checkboxes?["TOP_REQUIRED"], false)
            XCTAssertEqual(checkboxes?["TOP_REQUIRED_PRESELECTED"], true)
            XCTAssertEqual(checkboxes?["TOP_FORCED"], true)
            XCTAssertEqual(checkboxes?["TOP_FORCED_DISPLAYED"], true)
        }

        XCTContext.runActivity(named: "Test bottom extra elements") { _ in
            XCTAssertEqual(checkboxes?["BOTTOM_OPTIONAL"], false)
            XCTAssertEqual(checkboxes?["BOTTOM_OPTIONAL_PRESELECTED"], true)
            XCTAssertEqual(checkboxes?["BOTTOM_REQUIRED"], false)
            XCTAssertEqual(checkboxes?["BOTTOM_REQUIRED_PRESELECTED"], true)
            XCTAssertEqual(checkboxes?["BOTTOM_FORCED"], true)
            XCTAssertEqual(checkboxes?["BOTTOM_FORCED_DISPLAYED"], true)
        }
    }
}

private struct InputNetworkFactory {
    static func createInputNetworkWithExtraElements() throws -> Input.Network {
        let listResult = try loadListResult()

        let paymentNetwork = UIModel.PaymentNetwork(
            from: listResult.networks.applicable.first!,
            submitButtonLocalizableText: PaymentButtonLocalizableText(payment: nil, networkOperationType: "CHARGE"),
            localizeUsing: SharedTranslationProvider(localTranslations: [:])
        )

        let transformer: Input.ModelTransformer = {
            let context = UIModel.PaymentContext(operationType: .CHARGE, extraElements: listResult.extraElements)
            return .init(paymentContext: context)
        }()

        return try transformer.transform(paymentNetwork: paymentNetwork)
    }

    private static func loadListResult() throws -> ListResult {
        let url = Bundle.module.url(forResource: "ListResultWithExtraElements", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ListResult.self, from: data)
    }
}
