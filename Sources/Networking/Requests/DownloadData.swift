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
    struct DownloadData: GetRequest {
        public var url: URL
        public let queryItems = [URLQueryItem]()
        public typealias Response = Data

        /// - Parameter url: `self` link from payment session
        public init(from url: URL) {
            self.url = url
        }
    }
}

@available(iOS 14.0, *)
extension NetworkRequest.DownloadData: Loggable {
    public func logRequest() {
        logger.notice("[GET] ➡️ Download data from \(url, privacy: .private)")
    }

    public func logResponse(_ response: Data) {
        logger.notice("[GET] ✅ OK")
    }
}
