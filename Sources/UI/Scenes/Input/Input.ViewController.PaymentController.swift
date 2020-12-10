// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

protocol InputPaymentControllerDelegate: class {
    func paymentController(presentURL url: URL)
    func paymentController(route result: Result<OperationResult, ErrorInfo>)
    func paymentController(inputShouldBeChanged error: ErrorInfo)
    func paymentController(communicationDidFailWith error: ErrorInfo)
}

extension Input.ViewController {
    class PaymentController {
        let paymentServiceFactory: PaymentServicesFactory

        weak var delegate: InputPaymentControllerDelegate?

        init(paymentServiceFactory: PaymentServicesFactory) {
            self.paymentServiceFactory = paymentServiceFactory
        }
    }
}

extension Input.ViewController.PaymentController {
    func submitPayment(for network: Input.Network) {
         let service = paymentServiceFactory.createPaymentService(forNetworkCode: network.networkCode, paymentMethod: network.paymentMethod)
         service?.delegate = self

         var inputFieldsDictionary = [String: String]()
         var expiryDate: String?
         for element in network.uiModel.inputFields + network.uiModel.separatedCheckboxes {
             if element.name == "expiryDate" {
                 // Expiry date is processed below
                 expiryDate = element.value
                 continue
             }

             inputFieldsDictionary[element.name] = element.value
         }

         // Split expiry date
         if let expiryDate = expiryDate {
             inputFieldsDictionary["expiryMonth"] = String(expiryDate.prefix(2))
             inputFieldsDictionary["expiryYear"] = String(expiryDate.suffix(2))
         }

         let request = PaymentRequest(networkCode: network.networkCode, operationURL: network.operationURL, inputFields: inputFieldsDictionary)

         service?.send(paymentRequest: request)
     }
}

extension Input.ViewController.PaymentController: PaymentServiceDelegate {
    func paymentService(didReceiveResponse response: PaymentServiceParsedResponse) {
        switch response {
        case .redirect(let url):
            DispatchQueue.main.async {
                self.delegate?.paymentController(presentURL: url)
            }
        case .result(let result):
            // On retry show an error and leave on that view
            if case .RETRY = Interaction.Code(rawValue: result.errorInfo.interaction.code) {
                DispatchQueue.main.async {
                    self.delegate?.paymentController(inputShouldBeChanged: result.errorInfo)
                }
            }
            
            // If a reason is communication failure and code is ABORT (we shouldn't retry if it is VERIFY one), propose to retry
            else if case .ABORT = Interaction.Code(rawValue: result.errorInfo.interaction.code),
                    case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: result.errorInfo.interaction.reason) {
                // Propose to retry a charge request
                DispatchQueue.main.async {
                    self.delegate?.paymentController(communicationDidFailWith: result.errorInfo)
                }
            }
            
            // In other situations route to a parent view
            else {
                DispatchQueue.main.async {
                    self.delegate?.paymentController(route: result)
                }
            }
        }
    }
}
