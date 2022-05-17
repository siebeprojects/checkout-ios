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
    struct DownloadLocalization: GetRequest {
        public var url: URL
        public let queryItems = [URLQueryItem]()
        public typealias Response = [String: String]

        /// - Parameter url: `self` link from payment session
        public init(from url: URL) {
            self.url = url
        }
    }
}

@available(iOS 14.0, *)
extension NetworkRequest.DownloadLocalization: Loggable {
    private var localizationName: String {
        url.lastPathComponent.replacingOccurrences(of: ".json", with: "")
    }

    public func logRequest() {
        logger.info("[GET] ➡️ Localization for \(localizationName, privacy: .private)")
    }

    public func logResponse(_ response: [String: String]) {
        logger.info("[GET] ✅ Localization for \(localizationName, privacy: .private)")
    }
}
