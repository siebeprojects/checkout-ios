import UIKit

extension UIAlertController {
    /// Error with title and message, prefer using it in `UIAlertViewController`
    struct PreparedError: LocalizedError {
        let title: String?
        let message: String

        var underlyingError: Error?

        /// Block that should be called after alert dismissal
        var dismissBlock: (() -> Void)?
    }
}

extension UIAlertController.PreparedError {
    func createAlertController(translator: TranslationProvider) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let dismissLocalizedText: String = translator.translation(forKey: "button.ok.label")
        let dismissAction = UIAlertAction(title: dismissLocalizedText, style: .cancel) { [dismissBlock] _ in
            dismissBlock?()
        }
        alertController.addAction(dismissAction)

        return alertController
    }
}

// MARK: - Init from Error

extension UIAlertController.PreparedError {
    /// Show a default text for Error, error will be packed in `underlyingError`
    init(for error: Error, translator: TranslationProvider) {
        let title: String = translator.translation(forKey: "messages.error.default.title")
        let message: String = translator.translation(forKey: "messages.error.default.text")

        self.init(title: title, message: message)
        self.underlyingError = error
    }
}

// MARK: - Init from Interaction

extension UIAlertController.PreparedError {
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
