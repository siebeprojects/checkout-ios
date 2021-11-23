// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.ViewController {
    class PaymentController {
        let paymentContext: UIModel.PaymentContext
        let paymentServiceFactory: PaymentServicesFactory
        let operationResultHandler: OperationResultHandler

        weak var delegate: InputPaymentControllerDelegate?

        init(paymentServiceFactory: PaymentServicesFactory, paymentContext: UIModel.PaymentContext) {
            self.paymentServiceFactory = paymentServiceFactory
            self.paymentContext = paymentContext
            self.operationResultHandler = OperationResultHandler()
        }
    }
}

extension Input.ViewController.PaymentController {
    func delete(network: Input.Network) {
        let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
        service?.delegate = operationResultHandler

        guard let selfLink = network.apiModel.links?["self"] else {
            let error = InternalError(description: "API model doesn't contain links.self property")
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            delegate?.paymentController(didFailWith: errorInfo, for: nil)
            return
        }

        let request = DeletionRequest(accountURL: selfLink, operationType: network.apiModel.operationType)
        service?.send(operationRequest: request)
    }

    func submitOperation(for network: Input.Network) {
        guard let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod) else {
            let internalError = InternalError(description: "Unable to create payment service for network: %@", network.networkCode)
            let errorInfo = CustomErrorInfo.createClientSideError(from: internalError)
            delegate?.paymentController(didFailWith: errorInfo, for: nil)
            return
        }

        service.delegate = operationResultHandler

        do {
            let builder = PaymentRequestBuilder()
            let paymentRequest = try builder.createPaymentRequest(for: network)

            switch network.apiModel {
            case .preset(let presetAccount):
                // Manually create a response when submitting for a preset account (https://optile.atlassian.net/browse/PCX-996)
                let response = PresetResponseBuilder().createResponse(for: presetAccount)
                operationResultHandler.handle(response: response, for: paymentRequest)
            default:
                // Send a network request
                service.send(operationRequest: paymentRequest)
            }
        } catch {
            let errorInfo = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR), underlyingError: error)
            delegate?.paymentController(didFailWith: errorInfo, for: nil)
            return
        }
    }
}

// MARK: - PaymentRequestBuilder

private struct PaymentRequestBuilder: Loggable {
    /// Create a payment request with data from `Input.Network`
    ///
    /// - Warning: extra elements section will be ignored (to be implemented)
    func createPaymentRequest(for network: Input.Network) throws -> PaymentRequest {
        var paymentRequest = PaymentRequest(networkCode: network.networkCode, operationURL: network.operationURL, operationType: network.operationType)

        if let inputElementsSection = network.uiModel.inputSections[.inputElements] {
            paymentRequest.inputFields = try createDictionary(forInputElementsFields: inputElementsSection.inputFields)
        }

        if let registrationSection = network.uiModel.inputSections[.registration] {
            setRegistrationOptions(in: &paymentRequest, forRegistrationFields: registrationSection.inputFields)
        }

        return paymentRequest
    }

    private func createDictionary(forInputElementsFields inputFields: [InputField]) throws -> [String: String] {
        var dictionary = [String: String]()

        for inputField in inputFields {
            switch inputField.id {
            case .expiryDate:
                let date = ExpirationDate(shortDate: inputField.value)
                dictionary["expiryMonth"] = date.getMonth()
                dictionary["expiryYear"] = try date.getYear()
            case .inputElementName(let name):
                dictionary[name] = inputField.value
            default:
                if #available(iOS 14.0, *) {
                    logger.critical("Unexpected input field was found in input elements section: \(String(describing: inputField.id), privacy: .private)")
                }
            }
        }

        return dictionary
    }

    private func setRegistrationOptions(in paymentRequest: inout PaymentRequest, forRegistrationFields inputFields: [InputField]) {
        for inputField in inputFields {
            switch inputField.id {
            case .registration:
                paymentRequest.autoRegistration = Bool(stringValue: inputField.value)
            case .recurrence:
                paymentRequest.allowRecurrence = Bool(stringValue: inputField.value)
            case .combinedRegistration:
                let isOn = Bool(stringValue: inputField.value)
                paymentRequest.autoRegistration = isOn
                paymentRequest.allowRecurrence = isOn
            default:
                if #available(iOS 14.0, *) {
                    logger.critical("Unexpected input field was found in registration section: \(String(describing: inputField.id), privacy: .private)")
                }
            }
        }
    }
}

private struct ExpirationDate {
    /// Date in `MMYY` format
    let shortDate: String

    func getMonth() -> String {
        return String(shortDate.prefix(2))
    }

    func getYear() throws -> String {
        let shortYear = String(shortDate.suffix(2))
        return try DateFormatter.string(fromShortYear: shortYear)
    }
}
