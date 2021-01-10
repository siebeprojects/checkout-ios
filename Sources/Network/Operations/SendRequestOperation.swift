// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

class SendRequestOperation<T>: AsynchronousOperation where T: Request {
    let connection: Connection
    let request: T
    var downloadCompletionBlock: ((Result<T.Response, Error>) -> Void)?

    private(set) var result: Result<T.Response, Error>?

    init(connection: Connection, request: T) {
        self.connection = connection
        self.request = request
        super.init()
    }

    override func main() {
        var urlRequest: URLRequest

        do {
            urlRequest = try request.build()
        } catch {
            self.finish(with: .failure(error))
            return
        }

        let userAgentValue = VersionStringBuilder().createUserAgentValue()
        urlRequest.addValue(userAgentValue, forHTTPHeaderField: "User-Agent")
        print(userAgentValue)

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

