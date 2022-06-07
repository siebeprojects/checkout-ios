// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import SafariServices

public class RedirectController: NSObject {
    private var completionBlock: ((Result<OperationResult, Error>) -> Void)?

    private var viewController: UIViewController?
    private let callbackHandler: RedirectCallbackHandler

    public init(openAppWithURLNotificationName: NSNotification.Name) {
        self.callbackHandler = RedirectCallbackHandler(openAppWithURLNotificationName: openAppWithURLNotificationName)
    }

    public func createSafariController(presentingURL url: URL, completion: @escaping ((Result<OperationResult, Error>) -> Void)) -> SFSafariViewController {
        self.completionBlock = completion

        let viewController = SFSafariViewController(url: url)
        self.viewController = viewController
        viewController.delegate = self

        callbackHandler.addObserver { callbackResult in
            // We should capture self (don't mark self as weak) to ensure that class won't be deallocated and delegate will be called if user clicks "Done" button.
            viewController.dismiss(animated: true) {
                completion(callbackResult)
                self.completionBlock = nil
                self.viewController = nil
            }
        }

        return viewController
    }
}

// MARK: - SFSafariViewControllerDelegate

extension RedirectController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        callbackHandler.removeObserver()
        completionBlock?(.failure(RedirectError.missingOperationResult))
        completionBlock = nil
    }
}
