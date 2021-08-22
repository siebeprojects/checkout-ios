// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension UIAlertController {
    /// Error with title and message, prefer using it in `UIAlertViewController`
    struct AlertError: LocalizedError {
        let title: String?
        let message: String

        var underlyingError: Error?

        /// Alert window's actions
        var actions = [Action]()
    }
}

extension UIAlertController {
    struct Action {
        /// Button's label (localization key), e.g.: `button.ok.label`
        let label: LocalizationKey

        let style: UIAlertAction.Style

        /// Action to be executed when button is tapped
        let handler: ((UIAlertAction) -> Void)?
    }
}

extension UIAlertController.Action {
    enum LocalizationKey: String {
        case cancel = "button.cancel.label"
        case retry = "button.retry.label"
        case ok = "button.ok.label"
    }
}

extension UIAlertController.AlertError {
    func createAlertController(translator: TranslationProvider) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let alertActions: [UIAlertAction] = actions.map {
            let title: String = translator.translation(forKey: $0.label.rawValue)
            return .init(title: title, style: $0.style, handler: $0.handler)
        }

        alertActions.forEach { alertController.addAction($0) }

        return alertController
    }
}

// MARK: - Init from Error

extension UIAlertController.AlertError {
    /// Show a default text for Error, error will be packed in `underlyingError`
    init(for error: Error, translator: TranslationProvider) {
        let title: String = translator.translation(forKey: "messages.error.default.title")
        let message: String = translator.translation(forKey: "messages.error.default.text")

        self.init(title: title, message: message)
        self.underlyingError = error
    }
}

// MARK: - Init from Interaction

extension UIAlertController.AlertError {
    /// Initialize localized error if translator could translate both title and message
    init(for error: ErrorInfo, translator: TranslationProvider) {
        // If it is a communication error info, custom translations' keys should be used
        if case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: error.interaction.reason),
           let title = translator.translation(forKey: "messages.error.internet.title"),
           let message = translator.translation(forKey: "messages.error.internet.text") {
            self.init(title: title, message: message)
            return
        }

        let keys = Self.localizationKeys(for: error.interaction)

        if let title = translator.translation(forKey: keys.titleKey), let message = translator.translation(forKey: keys.messageKey) {
            // Localize using `interaction.CODE.REASON.title`
            self.init(title: title, message: message)
        } else {
            // Init with a generic error
            self.init(for: error as Error, translator: translator)
        }
    }

    /// Get keys in format that is used in localization files for specified `Interaction`
    private static func localizationKeys(for interaction: Interaction) -> (titleKey: String, messageKey: String) {
        var localizationKeyPrefix = "interaction."

        if let interaction = interaction as? LocalizableInteraction {
            localizationKeyPrefix += interaction.flow.localizationKey + "."
        }

        let titleKey = localizationKeyPrefix + "title"
        let messageKey = localizationKeyPrefix + "text"

        return (titleKey, messageKey)
    }
}

private extension Flow {
    var localizationKey: String { self.rawValue.uppercased() }
}
