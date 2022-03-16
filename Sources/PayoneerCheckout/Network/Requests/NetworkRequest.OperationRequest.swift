// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import os.log

// MARK: - Request

extension NetworkRequest {
    /// Request for an operation (`links.operation`).
    struct Charge: PostRequest {
        let url: URL
        let queryItems = [URLQueryItem]()
        var body: Body? { chargeBody }
        private let chargeBody: Body

        typealias Response = OperationResult

        /// - Parameter url: value from `links.operation` for charge operation
        init(from url: URL, body: Body) {
            self.url = url
            self.chargeBody = body
        }
    }
}

@available(iOS 14.0, *)
extension NetworkRequest.Charge {
    func logRequest(to logger: Logger) {
        logger.notice("[POST] ➡️ Operation request: \(url.absoluteString, privacy: .private)")
    }

    func logResponse(_ response: OperationResult, to logger: Logger) {
        logger.info("[POST] ✅ \(response.resultInfo, privacy: .private). Interaction: \(response.interaction.code, privacy: .private)/\(response.interaction.reason, privacy: .private)")
    }
}

// MARK: - Body

extension NetworkRequest.Charge {
    struct Body: Encodable {
        var account = [String: String]()
        var autoRegistration: Bool?
        var allowRecurrence: Bool?
        var providerRequest: ProviderParameters?
        var providerRequests: [ProviderParameters]?

        let browserData: BrowserData

        init(account: [String: String], autoRegistration: Bool?, allowRecurrence: Bool?, providerRequest: ProviderParameters?, providerRequests: [ProviderParameters]?) {
            self.account = account
            self.autoRegistration = autoRegistration
            self.allowRecurrence = allowRecurrence
            self.providerRequest = providerRequest
            self.providerRequests = providerRequests
            self.browserData = BrowserDataBuilder.build()
        }
    }
}
