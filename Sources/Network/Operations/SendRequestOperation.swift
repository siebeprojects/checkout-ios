// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class SendRequestOperation<T>: AsynchronousOperation where T: Request {
    let connection: Connection
    public let request: T
    public var downloadCompletionBlock: ((Result<T.Response, Error>) -> Void)?

    public private(set) var result: Result<T.Response, Error>?

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
        self.result = result
        downloadCompletionBlock?(result)
        finish()
    }
}
