import Foundation

enum TranslationKey: String, CaseIterable {
    case errorTitle = "messages.error.default.title"
    case errorText = "messages.error.default.text"

    case cancelLabel = "button.cancel.label"
    case retryLabel = "button.retry.label"

    var localizedString: String? {
        switch self {
        case .errorTitle: return "Oops!"
        case .errorText: return "An error occurred while handling your payment. Please try again."
        default: return nil
        }
    }
}
