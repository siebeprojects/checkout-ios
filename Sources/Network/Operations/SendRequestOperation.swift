import Foundation

public class SendRequestOperation<T>: AsynchronousOperation where T: Request {
    let connection: Connection
    public let request: T
    
    public var downloadCompletionBlock: ((Result<T.Response, Error>) -> Void)?

    public init(connection: Connection, request: T) {
        self.connection = connection
        self.request = request
        super.init()
    }

    public override func main() {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.build()
        } catch {
            self.finish(with: .failure(error))
            return
        }

        connection.send(request: urlRequest) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try self.request.decodeResponse(with: data)
                    self.finish(with: .success(decodedResponse))
                } catch {
                    self.finish(with: .failure(error))
                }
            case .failure(let error):
                self.finish(with: .failure(error))
            }
        }
    }
    
    private func finish(with result: Result<T.Response, Error>) {
        downloadCompletionBlock?(result)
        finish()
    }

    public override func cancel() {
        connection.cancel()
        super.cancel()
    }
}
