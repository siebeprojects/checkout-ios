// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.ViewController {
    class PaymentController {
        let paymentServiceFactory: PaymentServicesFactory
        let operationResultHandler: OperationResultHandler

        weak var delegate: InputPaymentControllerDelegate?

        init(paymentServiceFactory: PaymentServicesFactory, listOperationType: String) {
            self.paymentServiceFactory = paymentServiceFactory
            self.operationResultHandler = OperationResultHandler(listOperationType: listOperationType)
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

    func submitPayment(for network: Input.Network) {
        let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
        service?.delegate = operationResultHandler

        let inputFieldsDictionary: [String: String]
        do {
            let fabric = Input.ViewController.PaymentModelFabric()
            inputFieldsDictionary = try fabric.createInputFields(from: network)
        } catch {
            let errorInfo = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR), underlyingError: error)
            delegate?.paymentController(didFailWith: errorInfo, for: nil)
            return
        }

        let request = PaymentRequest(networkCode: network.networkCode, operationURL: network.operationURL, operationType: network.apiModel.operationType, inputFields: inputFieldsDictionary)

        service?.send(operationRequest: request)
    }
}


