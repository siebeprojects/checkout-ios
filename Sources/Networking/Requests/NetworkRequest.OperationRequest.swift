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
        public let queryItems = [URLQueryItem]()
        public var body: Body? { chargeBody }
        private let chargeBody: Body

        public typealias Response = OperationResult

        /// - Parameter url: value from `links.operation` for charge operation
        public init(from url: URL, body: Body) {
            self.url = url
            self.chargeBody = body
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

// MARK: - Body

public extension NetworkRequest.Operation {
    struct Body: Encodable {
        var account = [String: String]()
        var autoRegistration: Bool?
        var allowRecurrence: Bool?
        var providerRequests: [ProviderParameters]?

        let browserData: BrowserData

        public init(account: [String: String], autoRegistration: Bool?, allowRecurrence: Bool?, providerRequests: [ProviderParameters]?) {
            self.account = account
            self.autoRegistration = autoRegistration
            self.allowRecurrence = allowRecurrence
            self.providerRequests = providerRequests
            self.browserData = BrowserDataBuilder.build()
        }
    }
}
