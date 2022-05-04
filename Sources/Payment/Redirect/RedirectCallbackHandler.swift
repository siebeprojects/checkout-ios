// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

final class RedirectCallbackHandler {
    private let constants = Constant()

    private let openAppWithURLNotificationName: NSNotification.Name
    private var completionBlock: ((Result<OperationResult, Error>) -> Void)?
    private var receivePaymentNotificationToken: NSObjectProtocol?

    init(openAppWithURLNotificationName: NSNotification.Name) {
        self.openAppWithURLNotificationName = openAppWithURLNotificationName
    }

    func addObserver(completion: ((Result<OperationResult, Error>) -> Void)?) {
        // Remove observers to avoid duplicate completion calls if `addObservers()` were accidentally called twice
        removeObserver()

        self.completionBlock = completion

        // Received payment result notification
        receivePaymentNotificationToken = NotificationCenter.default.addObserver(forName: openAppWithURLNotificationName, object: nil, queue: .main) { [weak self] notification in
            guard let url = notification.userInfo?["url"] as? URL else { return }
            self?.handle(receivedURL: url)
            self?.removeObserver()
        }
    }

    func removeObserver() {
        if let receivePaymentNotificationToken = receivePaymentNotificationToken {
            NotificationCenter.default.removeObserver(receivePaymentNotificationToken)
            self.receivePaymentNotificationToken = nil
        }

        self.completionBlock = nil
    }

    private func handle(receivedURL: URL) {
        guard
            let components = URLComponents(url: receivedURL, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let interactionCode = queryItems.first(
                where: { $0.name == constants.interactionCodeKey }
            )?.name,
            let interactionReason = queryItems.first(
                where: { $0.name == constants.interactionReasonKey }
            )?.name
        else {
            completionBlock?(.failure(RedirectError.missingOperationResult))
            return
        }

        let queryItemsSlice = queryItems.drop {
            [constants.interactionCodeKey, constants.interactionReasonKey].contains($0.name)
        }

        let interaction = Interaction(code: interactionCode, reason: interactionReason)

        let parameters: [Parameter] = queryItemsSlice.map { .init(name: $0.name, value: $0.value) }
        let redirect = Redirect(url: receivedURL, method: .GET, parameters: parameters)

        let operationResult = OperationResult(resultInfo: "OperationResult received from the mobile-redirect webapp", links: nil, interaction: interaction, redirect: redirect)

        completionBlock?(.success(operationResult))
    }
}

// MARK: - Constants

private struct Constant {
    let interactionCodeKey = "interactionCode"
    let interactionReasonKey = "interactionReason"
}
