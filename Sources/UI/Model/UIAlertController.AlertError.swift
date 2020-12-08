// Copyright (c) 2020 optile GmbH
// https://www.optile.net
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

        var actions: [Action] = {
            [Action(label: .ok, handler: nil, style: .default)]
        }()

        struct Action {
            /// E.g.: `button.ok.label`
            let label: LocalizationKey

            /// Action to be executed when button is tapped
            let handler: ((UIAlertAction) -> Void)?

            let style: UIAlertAction.Style

            enum LocalizationKey: String {
                case ok = "button.ok.label"
            }
        }
    }
}

extension UIAlertController.AlertError {
    func createAlertController(translator: TranslationProvider) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let alertActions: [UIAlertAction] = actions.map {
            UIAlertAction(
                title: translator.translation(forKey: $0.label.rawValue),
                style: $0.style,
                handler: $0.handler
            )
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
    /// - Throws: `InternalError` with no localization description
    init(for interaction: Interaction, translator: TranslationProvider) throws {
        guard let title = translator.translation(forKey: interaction.localizableError.titleKey), let message = translator.translation(forKey: interaction.localizableError.messageKey) else {
            throw InternalError(description: "No translation for interaction with code and reason: %@", interaction)
        }

        self.init(title: title, message: message)
    }
}

private extension Interaction {
    /// Error that could be localized using given key for error's title and error's message. Lookup translations using `TranslationProvider`
    struct LocalizableError: Error {
        let titleKey: String
        let messageKey: String
    }

    var localizableError: LocalizableError {
        let localizationKeyPrefix = "interaction." + self.code + "." + self.reason + "."

        let titleKey = localizationKeyPrefix + "title"
        let messageKey = localizationKeyPrefix + "text"

        return LocalizableError(titleKey: titleKey, messageKey: messageKey)
    }
}
