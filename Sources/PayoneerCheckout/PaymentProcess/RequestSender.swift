// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Payment
import Logging

protocol RequestSenderDelegate: AnyObject {
    func requestSender(didReceiveResult result: Result<OperationResult, ErrorInfo>, for requestType: RequestSender.RequestType)
    func requestSender(presentationRequestReceivedFor viewController: UIViewController)
}

/// This class is responsible for sending operation and deletion requests to payment services, preparing models for payments service.
class RequestSender {
    private let paymentServiceFactory: PaymentServicesFactory
    let riskService: RiskService

    weak var delegate: RequestSenderDelegate?

    init(paymentServiceFactory: PaymentServicesFactory, riskService: RiskService) {
        self.paymentServiceFactory = paymentServiceFactory
        self.riskService = riskService
    }
}

extension RequestSender {
    func delete(network: Input.Network) {
        let requestType: RequestType = .deletion

        // Prepare models
        guard let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
        else {
            let error = RequestSenderError.paymentServiceNotFound(networkCode: network.networkCode, paymentMethod: network.paymentMethod)
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            delegate?.requestSender(didReceiveResult: .failure(errorInfo), for: requestType)
            return
        }

        guard let accountURL = network.apiModel.links?["self"] else {
            let error: RequestSenderError = .noSelfLink
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            delegate?.requestSender(didReceiveResult: .failure(errorInfo), for: requestType)
            return
        }

        // Delete account
        service.delete(accountUsing: accountURL, completion: { [weak self] operationResult, error in
            guard let weakSelf = self else { return }
            
            let deletionResult = weakSelf.convertToResult(object: operationResult, error: error)
            weakSelf.delegate?.requestSender(didReceiveResult: deletionResult, for: .deletion)
        }, presentationRequest: {
            delegate?.requestSender(presentationRequestReceivedFor: $0)
        })
    }

    func submitOperation(for network: Input.Network) {
        let requestType: RequestType = .operation(type: network.operationType)

        // Prepare models
        guard let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
        else {
            let error = RequestSenderError.paymentServiceNotFound(networkCode: network.networkCode, paymentMethod: network.paymentMethod)
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            delegate?.requestSender(didReceiveResult: .failure(errorInfo), for: requestType)
            return
        }

        let operationRequest: OperationRequest

        do {
            let builder = PaymentRequestBuilder(riskService: riskService)
            operationRequest = try builder.createPaymentRequest(for: network)
        } catch {
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            delegate?.requestSender(didReceiveResult: .failure(errorInfo), for: requestType)
            return
        }

        // Send operation request
        service.send(operationRequest: operationRequest, completion: { [weak self] operationResult, error in
            guard let weakSelf = self else { return }

            let operationResult = weakSelf.convertToResult(object: operationResult, error: error)
            weakSelf.delegate?.requestSender(didReceiveResult: operationResult, for: .operation(type: network.operationType))
        }, presentationRequest: { [delegate] in
            delegate?.requestSender(presentationRequestReceivedFor: $0)
        })
    }

    /// Converts object and error optionals to `Result` with a defined state.
    private func convertToResult<T>(object: T?, error: Error?) -> Result <T, ErrorInfo> {
        if let errorInfo = error as? ErrorInfo {
            return .failure(errorInfo)
        } else if let error = error {
            return .failure(CustomErrorInfo.createClientSideError(from: error))
        }

        guard let object = object else {
            let error = RequestSenderError.malformedResponseBlock
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            return .failure(errorInfo)
        }

        return .success(object)
    }
}

// MARK: - PaymentRequestBuilder

private struct PaymentRequestBuilder: Loggable {
    let riskService: RiskService

    /// Create a payment request with data from `Input.Network`
    ///
    /// - Warning: extra elements section will be ignored (to be implemented)
    func createPaymentRequest(for network: Input.Network) throws -> OperationRequest {
        // Network information
        let networkInformation = NetworkInformation(networkCode: network.networkCode, paymentMethod: network.paymentMethod, operationType: network.operationType, links: network.apiModel.links ?? [:])

        // Form
        let inputFields: [String: String] = try {
            guard let inputElementsSection = network.uiModel.inputSections[.inputElements] else {
                return [:]
            }

            return try createDictionary(forInputElementsFields: inputElementsSection.inputFields)
        }()


        let autoRegistration, allowRecurrence: Bool?
        (autoRegistration, allowRecurrence) = {
            guard let registrationSection = network.uiModel.inputSections[.registration] else {
                return (nil, nil)
            }

            return createRegistrationOptions(forRegistrationFields: registrationSection.inputFields)
        }()

        let form = Form(inputFields: inputFields, autoRegistration: autoRegistration, allowRecurrence: allowRecurrence)

        let riskData = riskService.collectRiskData()

        let operationRequest = OperationRequest(networkInformation: networkInformation, form: form, riskData: riskData)

        return operationRequest
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

    private func createRegistrationOptions(forRegistrationFields inputFields: [InputField]) -> (autoRegistration: Bool?, allowRecurrence: Bool?) {
        var autoRegistration, allowRecurrence: Bool?

        for inputField in inputFields {
            switch inputField.id {
            case .registration:
                autoRegistration = Bool(stringValue: inputField.value)
            case .recurrence:
                allowRecurrence = Bool(stringValue: inputField.value)
            case .combinedRegistration:
                let isOn = Bool(stringValue: inputField.value)
                autoRegistration = isOn
                allowRecurrence = isOn
            default:
                if #available(iOS 14.0, *) {
                    logger.critical("Unexpected input field was found in registration section: \(String(describing: inputField.id), privacy: .private)")
                }
            }
        }

        return (autoRegistration, allowRecurrence)
    }

    // MARK: ExpirationDate

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
}

// MARK: - RequestType

extension RequestSender {
    enum RequestType {
        case operation(type: String)
        case deletion
    }
}

// MARK: - Error

private enum RequestSenderError: LocalizedError {
    case paymentServiceNotFound(networkCode: String, paymentMethod: String?)
    case noSelfLink
    case malformedResponseBlock

    var errorDescription: String? {
        switch self {
        case .paymentServiceNotFound(let code, let method):
            return "Payment service for network code: " + code + " or method: " + (method ?? "n/a") + "wasn't found"
        case .noSelfLink:
            return "Links.self is missing in account object"
        case .malformedResponseBlock:
            return "Malformed response: both data and error objects are nil"
        }
    }
}
