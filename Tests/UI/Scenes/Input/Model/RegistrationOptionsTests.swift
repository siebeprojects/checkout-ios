// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout

class RegistrationOptionsTests: XCTestCase {
    private let localizationProvider = MockFactory.Localization.provider

    func testChargeFlow() {
        let context = PaymentContext(operationType: .CHARGE, extraElements: nil)
        let modelTransformer = Input.ModelTransformer(paymentContext: context)

        for testingCase in testingCasesForChargeFlow {
            XCTContext.runActivity(named: "Testing \(testingCase.registration) / \(testingCase.recurrence)") { _ in
                let inputNetwork: Input.Network

                do {
                    let network = createNetwork(for: testingCase)
                    inputNetwork = try modelTransformer.transform(paymentNetwork: network)
                } catch {
                    XCTFail(error)
                    return
                }

                XCTAssertEqual(inputNetwork.uiModel.inputSections.count, 2, "Network contains invalid number of sections")
                guard let registrationSection = inputNetwork.uiModel.inputSections[.registration] else {
                    XCTFail("Registration section is not found")
                    return
                }

                testingCase.expectations.assertEqual(to: registrationSection.inputFields)
            }
        }
    }

    private func createNetwork(for model: TestingCase) -> PaymentNetwork {
        let applicableNetwork = ApplicableNetwork(code: "", label: "", method: "", grouping: "", registration: model.registration, recurrence: model.recurrence, redirect: false, inputElements: nil, links: ["operation": URL(string: "https://example.com")!], operationType: "CHARGE")
        return PaymentNetwork(from: applicableNetwork, submitButtonLocalizationKey: "", localizeUsing: localizationProvider)
    }
}

// MARK: Testing Cases

private struct TestingCase {
    let registration: ApplicableNetwork.RegistrationOption
    let recurrence: ApplicableNetwork.RegistrationOption
    let expectations: [RegistrationExpectation]
}

private var testingCasesForChargeFlow: [TestingCase] {
    [
        .init(registration: .NONE, recurrence: .NONE, expectations: []),
        .init(registration: .FORCED, recurrence: .NONE, expectations: [
            .init(id: .registration, inputFieldType: Input.Field.Hidden.self, value: true)
        ]),
        .init(registration: .FORCED_DISPLAYED, recurrence: .NONE, expectations: [
            .init(id: .registration, inputFieldType: Input.Field.Label.self, value: true)
        ]),
        .init(registration: .FORCED, recurrence: .FORCED, expectations: [
            .init(id: .registration, inputFieldType: Input.Field.Hidden.self, value: true),
            .init(id: .recurrence, inputFieldType: Input.Field.Hidden.self, value: true)
        ]),
        .init(registration: .FORCED_DISPLAYED, recurrence: .FORCED_DISPLAYED, expectations: [
            .init(id: .registration, inputFieldType: Input.Field.Label.self, value: true),
            .init(id: .recurrence, inputFieldType: Input.Field.Hidden.self, value: true)
        ]),
        .init(registration: .OPTIONAL, recurrence: .NONE, expectations: [
            .init(id: .registration, inputFieldType: Input.Field.Checkbox.self, value: false)
        ]),
        .init(registration: .OPTIONAL_PRESELECTED, recurrence: .NONE, expectations: [
            .init(id: .registration, inputFieldType: Input.Field.Checkbox.self, value: true)
        ]),
        .init(registration: .OPTIONAL, recurrence: .OPTIONAL, expectations: [
            .init(id: .combinedRegistration, inputFieldType: Input.Field.Checkbox.self, value: false)
        ]),
        .init(registration: .OPTIONAL_PRESELECTED, recurrence: .OPTIONAL_PRESELECTED, expectations: [
            .init(id: .combinedRegistration, inputFieldType: Input.Field.Checkbox.self, value: true)
        ])
    ]
}

// MARK: - RegistrationExpectation

private extension RegistrationExpectation {
    static func == (lhs: RegistrationExpectation, rhs: InputField) -> Bool {
        return lhs.inputFieldType === type(of: rhs) && lhs.id == rhs.id && lhs.value.stringValue == rhs.value
    }
}

private struct RegistrationExpectation {
    let id: Input.Field.Identifier
    let inputFieldType: InputField.Type
    let value: Bool
}

private extension Collection where Element == RegistrationExpectation {
    func assertEqual(to inputFields: [InputField]) {
        XCTAssertEqual(inputFields.count, self.count, "Array contains different number of elements")

        for inputField in inputFields {
            if !self.contains(where: { $0 == inputField }) {
                XCTFail("Unable to find expectation for \(inputField)")
            }
        }
    }
}
