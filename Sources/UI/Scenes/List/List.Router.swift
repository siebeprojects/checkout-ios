import UIKit

extension List {
    class Router {
        weak var rootViewController: UIViewController?
        let paymentServicesFactory: PaymentServicesFactory
        lazy fileprivate private(set) var slideInPresentationManager = SlideInPresentationManager()
        
        init(paymentServicesFactory: PaymentServicesFactory) {
            self.paymentServicesFactory = paymentServicesFactory
        }
    }
}

extension List.Router {
    func present(paymentNetworks: [PaymentNetwork], operationType: ListResult.OperationType, animated: Bool) throws -> Input.ViewController {
        let inputViewController = try Input.ViewController(for: paymentNetworks, paymentServiceFactory: paymentServicesFactory, operationType: operationType)
        
        let style: PresentationStyle
        if paymentNetworks.count == 1 && !inputViewController.hasInputFields {
            style = .bottomSlideIn
        } else {
            style = .modal
        }
        
        present(inputViewController: inputViewController, operationType: operationType, animated: animated, usingStyle: style)
        return inputViewController
    }

    func present(registeredAccount: RegisteredAccount, operationType: ListResult.OperationType, animated: Bool) throws -> Input.ViewController {
        let inputViewController = try Input.ViewController(for: registeredAccount, paymentServiceFactory: paymentServicesFactory, operationType: operationType)
        present(inputViewController: inputViewController, operationType: operationType, animated: animated, usingStyle: .bottomSlideIn)
        return inputViewController
    }
}

private extension List.Router {
    func present(inputViewController: Input.ViewController, operationType: ListResult.OperationType, animated: Bool, usingStyle style: PresentationStyle) {
        let navigationController = Input.NavigationController(rootViewController: inputViewController)
        
        if !inputViewController.hasInputFields {
            setSlideInPresentationStyle(for: navigationController)
        }

        rootViewController?.present(navigationController, animated: animated, completion: nil)
    }
    
    private func setSlideInPresentationStyle(for viewController: UIViewController) {
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = slideInPresentationManager
    }
}

private enum PresentationStyle {
    case modal, bottomSlideIn
}
