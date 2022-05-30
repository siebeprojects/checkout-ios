// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Logging

// MARK: - Request

public extension NetworkRequest {
    /// Gets active LIST session details
    ///
    /// Retrieves available payment capabilities for active `LIST` session.
    struct GetListResult: GetRequest {
        public var url: URL
        public let queryItems = [URLQueryItem]()
        public typealias Response = ListResult

        /// - Parameter url: `self` link from payment session
        public init(url: URL) {
            self.url = url
        }
    }
}

@available(iOS 14.0, *)
extension NetworkRequest.GetListResult: Loggable {
    public func logRequest() {
        logger.notice("[GET] ➡️ Payment session for \(url.lastPathComponent, privacy: .private(mask: .hash))")
    }

    public func logResponse(_ response: ListResult) {
        logger.notice("[GET] ✅ \(response.resultInfo, privacy: .private)")
    }
}





// TODO: Temp

public extension NetworkRequest {
    struct OnSelectRequest: PostRequest {
        public var url: URL
        public let body: EmptyObject? = EmptyObject()
        public let queryItems: [URLQueryItem] = []

        public typealias Response = OperationResult

        /// - Parameter url: `self` link from payment session
        public init(url: URL) {
            self.url = url
        }
    }
}

public extension NetworkRequest.OnSelectRequest {
    struct EmptyObject: Encodable {
        fileprivate init() {}
    }
}


@available(iOS 14.0, *)
extension NetworkRequest.OnSelectRequest: Loggable {
    public func logRequest() {
        logger.notice("[POST] ➡️ OnSelect call")
    }

    public func logResponse(_ response: Response) {
        logger.notice("[POST] ✅ \(response.resultInfo, privacy: .private)")
    }
}
