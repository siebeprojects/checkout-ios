import Foundation

struct PaymentError: LocalizedError {
    var localizedDescription: String
    var underlyingError: Error?
    var errorDescription: String? { return localizedDescription}
}
