// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

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
    func present(paymentNetworks: [PaymentNetwork], listOperationType: String, animated: Bool) throws -> Input.ViewController {
        let inputViewController = try Input.ViewController(for: paymentNetworks, paymentServiceFactory: paymentServicesFactory, operationType: listOperationType)

        let style: PresentationStyle
        if paymentNetworks.count == 1 && !inputViewController.hasInputFields {
            style = .bottomSlideIn
        } else {
            style = .modal
        }

        present(inputViewController: inputViewController, animated: animated, usingStyle: style)
        return inputViewController
    }

    func present(registeredAccount: RegisteredAccount, listOperationType: String, animated: Bool) throws -> Input.ViewController {
        let inputViewController = try Input.ViewController(for: registeredAccount, paymentServiceFactory: paymentServicesFactory, operationType: listOperationType)
        present(inputViewController: inputViewController, animated: animated, usingStyle: .bottomSlideIn)
        return inputViewController
    }
}

private extension List.Router {
    func present(inputViewController: Input.ViewController, animated: Bool, usingStyle style: PresentationStyle) {
        let navigationController = Input.NavigationController(rootViewController: inputViewController)

        if let customFont = Theme.shared.font {
            navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: customFont]
        }

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
