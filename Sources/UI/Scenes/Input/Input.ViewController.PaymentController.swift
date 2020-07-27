import Foundation

protocol PaymentControllerDelegate: class {
    func paymentController(paymentCompleteWith result: PaymentResult)
    
    /// Payment has been failed and an error should be displayed
    /// - Parameters:
    ///   - isRetryable: user may correct an input, view shouldn't be dismissed
    func paymentController(paymentFailedWith error: Error, withResult result: PaymentResult, isRetryable: Bool)
}

extension Input.ViewController {
    class PaymentController {
        let paymentServiceFactory: PaymentServicesFactory

        weak var delegate: PaymentControllerDelegate?

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
    func paymentService(receivedPaymentResult paymentResult: PaymentResult) {
        switch Interaction.Code(rawValue: paymentResult.interaction.code) {
        case .PROCEED, .ABORT, .VERIFY, .RELOAD:
            delegate?.paymentController(paymentCompleteWith: paymentResult)
        case .RETRY:
            let error = Input.LocalizableError(interaction: paymentResult.interaction)
            delegate?.paymentController(paymentFailedWith: error, withResult: paymentResult, isRetryable: true)
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            let error = Input.LocalizableError(interaction: paymentResult.interaction)
            delegate?.paymentController(paymentFailedWith: error, withResult: paymentResult, isRetryable: false)
        case .none:
            // Unknown interaction code was met
            delegate?.paymentController(paymentCompleteWith: paymentResult)
        }
    }
}

private extension Input.LocalizableError {
    init(interaction: Interaction) {
        let localizationKeyPrefix = "interaction." + interaction.code + "." + interaction.reason + "."

        titleKey = localizationKeyPrefix + "title"
        messageKey = localizationKeyPrefix + "reason"
    }
}
