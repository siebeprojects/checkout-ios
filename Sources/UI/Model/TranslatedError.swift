import Foundation

struct TranslatedError: LocalizedError {
    var localizedDescription: String
    var underlyingError: Error?
    var errorDescription: String? { return localizedDescription}
}
