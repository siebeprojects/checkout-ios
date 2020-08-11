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
    func present(paymentNetworks: [PaymentNetwork], animated: Bool) throws -> Input.ViewController {
        let inputViewController = try Input.ViewController(for: paymentNetworks, paymentServiceFactory: paymentServicesFactory)
        present(inputViewController: inputViewController, animated: animated)
        return inputViewController
    }

    func present(registeredAccount: RegisteredAccount, animated: Bool) throws -> Input.ViewController {
        let inputViewController = try Input.ViewController(for: registeredAccount, paymentServiceFactory: paymentServicesFactory)
        present(inputViewController: inputViewController, animated: animated)
        return inputViewController
    }
}

private extension List.Router {
    func present(inputViewController: Input.ViewController, animated: Bool) {
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
