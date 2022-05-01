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
        callbackHandler.addObserver { [weak self] callbackResult in
            completion(callbackResult)
            self?.completionBlock = nil
        }
        self.completionBlock = completion

        let viewController = SFSafariViewController(url: url)
        self.viewController = viewController
        viewController.delegate = self
        return viewController
    }
}

extension RedirectController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        callbackHandler.removeObserver()
        completionBlock?(.failure(RedirectionError.missingOperationResult))
        completionBlock = nil
    }
}
