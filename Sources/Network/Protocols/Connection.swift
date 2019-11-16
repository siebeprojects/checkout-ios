import Foundation

/// Protocol responsible for sending requests, maybe faked when unit testing
/// - Warning: connection maybe called from `Operation` and it is not thread-safe, be very carefull writing data when share one connection between multiple operations.
public protocol Connection {
    func send(request: URLRequest, completionHandler: @escaping ((Result<Data?, Error>) -> Void))
    func cancel()
}
