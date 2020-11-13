// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = SlideInPresentationController(presentedViewController: presented, presenting: presenting)
        controller.delegate = self
        return controller
    }
}

extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        presentationController.containerView?.setNeedsLayout()
    }
}
