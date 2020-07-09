import Foundation

extension Input {
    /// Error that should be displayed to the user
    struct LocalizableError: Error {
        let titleKey: String
        let messageKey: String
    }
}
