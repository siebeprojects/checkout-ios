import Foundation

protocol InputPaymentControllerDelegate: class {
    func paymentController(presentURL url: URL)
    func paymentController(route result: Result<OperationResult, ErrorInfo>)
    func paymentController(presentAlertFor interaction: Interaction)
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
            switch Interaction.Code(rawValue: result.interaction.code) {
            case .RETRY:
                // On retry show an error and leave on that view
                DispatchQueue.main.async {
                    self.delegate?.paymentController(presentAlertFor: result.interaction)
                }
            default:
                // Route result to other view
                DispatchQueue.main.async {
                    self.delegate?.paymentController(route: result)
                }
            }
        }
    }
}
