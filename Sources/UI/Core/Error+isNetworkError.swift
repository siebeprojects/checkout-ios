import Foundation

extension Error {
    /// Returns NSError if `Self` is a retryable network error, otherwhise returns `nil`.
	var asNetworkError: NSError? {
		let nsError = self as NSError
		
		let allowedCodes: [URLError.Code] = [.notConnectedToInternet, .dataNotAllowed]
		let allowedCodesNumber = allowedCodes.map { $0.rawValue }
		if nsError.domain == NSURLErrorDomain, allowedCodesNumber.contains(nsError.code) {
			return nsError
		} else {
			return nil
		}
	}
}
