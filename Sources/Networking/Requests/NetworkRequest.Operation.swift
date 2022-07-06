// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Logging

// MARK: - Request

public extension NetworkRequest {
    /// Request for an operation (`links.operation`).
    struct Operation: PostRequest {
        public let url: URL
        public let queryItems: [URLQueryItem]
        public var body: OperationData?

        public typealias Response = OperationResult

        /// - Parameter url: value from `links.operation` for charge operation
        public init(from url: URL, account: [String: String]?, autoRegistration: Bool?, allowRecurrence: Bool?, providerRequest: ProviderParameters?, providerRequests: [ProviderParameters]?) {
            self.url = url
            self.queryItems = []
            self.body = OperationData(
                account: account,
                autoRegistration: autoRegistration,
                allowRecurrence: allowRecurrence,
                providerRequest: providerRequest,
                providerRequests: providerRequests,
                browserData: BrowserDataBuilder.build()
            )
        }
    }
}

@available(iOS 14.0, *)
extension NetworkRequest.Operation: Loggable {
    public func logRequest() {
        logger.notice("[POST] ➡️ Operation request: \(url.absoluteString, privacy: .private)")
    }

    public func logResponse(_ response: OperationResult) {
        logger.info("[POST] ✅ \(response.resultInfo, privacy: .private). Interaction: \(response.interaction.code, privacy: .private)/\(response.interaction.reason, privacy: .private)")
    }
}
