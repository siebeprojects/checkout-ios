// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import UIKit

// MARK: Constants

extension Input.ModelTransformer {
    struct Constant {
        static var ignoredFields: [IgnoredFields] { [
            .init(networkCode: "SEPADD", inputElementName: "bic")
        ] }

        static var registrationCheckboxLocalizationKey: String { "autoRegistrationLabel" }
        static var recurrenceCheckboxLocalizationKey: String { "allowRecurrenceLabel" }
    }
}

// MARK: - Transformer

extension Input {
    /// Transformer from `List` models to `Input` UI models.
    class ModelTransformer {
        fileprivate let inputFieldFactory = InputElementsTransformer()
        let paymentContext: UIModel.PaymentContext

        init(paymentContext: UIModel.PaymentContext) {
            self.paymentContext = paymentContext
        }
    }
}

extension Input.ModelTransformer {
    private typealias InputSection = Input.Network.UIModel.InputSection

    func transform(presetAccount: UIModel.PresetAccount) throws -> Input.Network {
        let logo = presetAccount.logo?.value

        var sections = Set<InputSection>()

        if let extraElements = paymentContext.extraElements {
            let extraElementsSections = createInputSections(from: extraElements)
            sections.formUnion(extraElementsSections)
        }

        // Operation URL
        guard let operationURL = presetAccount.apiModel.links["operation"] else {
            throw InternalError(description: "Incorrect preset account model, operation URL is not present. Links: %@", objects: presetAccount.apiModel.links)
        }

        let submitButton = Input.Field.Button(label: presetAccount.submitButtonLabel)

        let uiModel = Input.Network.UIModel(
            networkLabel: presetAccount.networkLabel,
            maskedAccountLabel: presetAccount.maskedAccountLabel,
            logo: logo,
            inputSections: sections,
            submitButton: submitButton
        )

        return .init(
            apiModel: .preset(presetAccount.apiModel),
            operationURL: operationURL,
            paymentMethod: presetAccount.apiModel.method,
            networkCode: presetAccount.apiModel.code,
            translator: presetAccount.translation,
            switchRule: nil,
            uiModel: uiModel,
            isDeletable: false
        )
    }
    
    func transform(registeredAccount: UIModel.RegisteredAccount) throws -> Input.Network {
        let logo = registeredAccount.logo?.value

        // Input sections
        let inputElements = registeredAccount.apiModel.inputElements ?? [InputElement]()
        let modelToTransform = InputElementsTransformer.TransformableModel(inputElements: inputElements, networkCode: registeredAccount.apiModel.code, paymentMethod: nil, translator: registeredAccount.translation)

        let accountInputFields = inputFieldFactory.createInputFields(for: modelToTransform)

        var inputSections: Set<InputSection> = [
            .init(category: .inputElements, inputFields: accountInputFields)
        ]

        if let extraElements = paymentContext.extraElements {
            let extraElementsSections = createInputSections(from: extraElements)
            inputSections.formUnion(extraElementsSections)
        }

        // Operation URL
        guard let operationURL = registeredAccount.apiModel.links["operation"] else {
            throw InternalError(description: "Incorrect registered account model, operation URL is not present. Links: %@", objects: registeredAccount.apiModel.links)
        }

        // Check if we need to show a submit button
        let submitButton: Input.Field.Button?
        if registeredAccount.apiModel.operationType == "UPDATE", accountInputFields.isEmpty {
            submitButton = nil
        } else {
            submitButton = Input.Field.Button(label: registeredAccount.submitButtonLabel)
        }

        let uiModel = Input.Network.UIModel(
            networkLabel: registeredAccount.networkLabel,
            maskedAccountLabel: registeredAccount.maskedAccountLabel,
            logo: logo,
            inputSections: inputSections,
            submitButton: submitButton
        )

        return .init(
            apiModel: .account(registeredAccount.apiModel),
            operationURL: operationURL,
            paymentMethod: registeredAccount.apiModel.method,
            networkCode: registeredAccount.apiModel.code,
            translator: registeredAccount.translation,
            switchRule: nil,
            uiModel: uiModel,
            isDeletable: registeredAccount.isDeletable
        )
    }

    func transform(paymentNetwork: UIModel.PaymentNetwork) throws -> Input.Network {
        let logo = paymentNetwork.logo?.value

        // Input fields
        let inputElements = paymentNetwork.applicableNetwork.inputElements ?? [InputElement]()

        let modelToTransform = InputElementsTransformer.TransformableModel(
            inputElements: inputElements,
            networkCode: paymentNetwork.applicableNetwork.code,
            paymentMethod: paymentNetwork.applicableNetwork.method,
            translator: paymentNetwork.translation
        )

        // Switch rule
        let smartSwitchRule = switchRule(forNetworkCode: paymentNetwork.applicableNetwork.code)

        // Registration options
        let checkboxFactory = RegistrationOptionsBuilder(translator: paymentNetwork.translation, listOperationType: paymentContext.listOperationType)
        let registrationInputFields = try checkboxFactory.createInternalModel(fromRegistration: paymentNetwork.applicableNetwork.registration, reccurrence: paymentNetwork.applicableNetwork.recurrence)

        let paymentInputFields = inputFieldFactory.createInputFields(for: modelToTransform)

        var inputSections: Set<InputSection> = [
            .init(category: .inputElements, inputFields: paymentInputFields),
            .init(category: .registration, inputFields: registrationInputFields)
        ]

        if let extraElements = paymentContext.extraElements {
            let extraElementsSections = createInputSections(from: extraElements)
            inputSections.formUnion(extraElementsSections)
        }

        let submitButton = Input.Field.Button(label: paymentNetwork.submitButtonLabel)

        let uiModel = Input.Network.UIModel(networkLabel: paymentNetwork.label,
                                            maskedAccountLabel: nil,
                                            logo: logo,
                                            inputSections: inputSections,
                                            submitButton: submitButton)

        // Operation URL
        guard let operationURL = paymentNetwork.applicableNetwork.links?["operation"] else {
            throw InternalError(description: "Incorrect applicable network model, operation URL is not present. Links: %@", objects: paymentNetwork.applicableNetwork.links)
        }

        return .init(apiModel: .network(paymentNetwork.applicableNetwork),
                     operationURL: operationURL,
                     paymentMethod: paymentNetwork.applicableNetwork.method,
                     networkCode: paymentNetwork.applicableNetwork.code,
                     translator: paymentNetwork.translation,
                     switchRule: smartSwitchRule,
                     uiModel: uiModel,
                     isDeletable: false)
    }

    /// Create `InputSection` for top and bottom `ExtraElement`s.
    private func createInputSections(from extraElements: ExtraElements) -> Set<InputSection> {
        var inputSections = Set<InputSection>()

        let extraElementsTransformer = ExtraElementsTransformer()

        if let topElements = extraElements.top {
            let inputFields = topElements.compactMap { extraElementsTransformer.createInputField(from: $0) }
            let section = InputSection(category: .extraElements(at: .top), inputFields: inputFields)
            inputSections.insert(section)
        }

        if let bottomElements = extraElements.bottom {
            let inputFields = bottomElements.compactMap { extraElementsTransformer.createInputField(from: $0) }
            let section = InputSection(category: .extraElements(at: .bottom), inputFields: inputFields)
            inputSections.insert(section)
        }

        return inputSections
    }

    // MARK: Smart Switch

    /// Get SmartSwitch rule for a network
    private func switchRule(forNetworkCode networkCode: String) -> Input.SmartSwitch.Rule? {
        do {
            let switchProvider = Input.SmartSwitch.Provider()
            return try switchProvider.getRules().first(withCode: networkCode)
        } catch {
            let internalError = InternalError(description: "Unable to decode smart switch rules: %@", objects: error)
            internalError.log()

            return nil
        }
    }
}

extension Input.ModelTransformer {
    struct IgnoredFields {
        let networkCode: String
        let inputElementName: String
    }
}
