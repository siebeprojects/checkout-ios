// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Logging
import os.log

// MARK: - Constants

private extension String {
    static var httpVendorHeader: String { "application/vnd.optile.payment.enterprise-v1-extensible+json" }
}

// MARK: - SendRequestOperation

open class SendRequestOperation<T>: AsynchronousOperation where T: Request {
    let connection: Connection
    let request: T
    public var downloadCompletionBlock: ((Result<T.Response, Error>) -> Void)?

    private(set) public var result: Result<T.Response, Error>?

    public init(connection: Connection, request: T) {
        self.connection = connection
        self.request = request
        super.init()
    }

    public override func main() {
        var urlRequest: URLRequest

        do {
            urlRequest = try request.build()
        } catch {
            self.finish(with: .failure(error))
            return
        }

        let userAgentValue = UserAgentBuilder().createUserAgentValue()
        urlRequest.addValue(userAgentValue, forHTTPHeaderField: "User-Agent")

        urlRequest.addValue(.httpVendorHeader, forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(.httpVendorHeader, forHTTPHeaderField: "Accept")

        if #available(iOS 14.0, *) {
            request.logRequest()
        }

        connection.send(request: urlRequest) { (data, error) in
            if let error = error {
                if #available(iOS 14.0, *) { self.log(error: error) }
                self.finish(with: .failure(error))
                return
            }

            guard let data = data else {
                let error = NetworkError(description: "Response doesn't contain data and error")
                if #available(iOS 14.0, *) { self.log(error: error) }
                self.finish(with: .failure(error))
                return
            }

            do {
                let decodedResponse = try self.request.decodeResponse(with: data)
                if #available(iOS 14.0, *) {
                    self.request.logResponse(decodedResponse)
                }
                self.finish(with: .success(decodedResponse))
            } catch {
                if #available(iOS 14.0, *) { self.log(error: error) }
                self.finish(with: .failure(error))
            }
        }
    }

    @available(iOS 14.0, *)
    private func log(error: Error) {
        if let errorInfo = error as? ErrorInfo {
            request.logger.error("⛔️ \(errorInfo.resultInfo, privacy: .private). Interaction: \(errorInfo.interaction.code, privacy: .private)/\(errorInfo.interaction.reason, privacy: .private)")
        } else {
            request.logger.error("⛔️ \(error.localizedDescription, privacy: .private)")
        }
    }

    private func finish(with result: Result<T.Response, Error>) {
        self.result = result
        downloadCompletionBlock?(result)
        finish()
    }
}
