import Foundation

protocol PaymentControllerDelegate: class {
    func paymentController(paymentSucceedWith result: OperationResult?)
    func paymentController(paymentFailedWith error: Error, unwindAction: Input.ViewController.UnwindAction?)
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
    func paymentService(_ paymentService: PaymentService, paymentResult: PaymentResult) {
        debugPrint(paymentResult.interaction.code)
        debugPrint(paymentResult.interaction.reason)
        let code = Interaction.Code(rawValue: paymentResult.interaction.code)
        switch code {
        case .PROCEED:
            delegate?.paymentController(paymentSucceedWith: paymentResult.operationResult)
        case .RETRY:
            let error = Input.LocalizableError(interaction: paymentResult.interaction)
            delegate?.paymentController(paymentFailedWith: error, unwindAction: nil)
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            let unwindAction: Input.ViewController.UnwindAction
            switch code {
            case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK: unwindAction = .reloadList
            default: unwindAction = .dismiss
            }

            let error = Input.LocalizableError(interaction: paymentResult.interaction)
            delegate?.paymentController(paymentFailedWith: error, unwindAction: unwindAction)
        default:
            let error = paymentResult.error ?? InternalError(description: "Error interaction code: %@", paymentResult.interaction.code)
            delegate?.paymentController(paymentFailedWith: error, unwindAction: .dismiss)
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
