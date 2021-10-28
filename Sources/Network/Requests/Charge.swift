// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import os.log

// MARK: - Request

/// Request for `CHARGE` operation.
struct Charge: PostRequest {
    let url: URL
    let queryItems = [URLQueryItem]()
    var body: Body? { chargeBody }
    private let chargeBody: Body

    var operationType: String { url.lastPathComponent }

    typealias Response = OperationResult

    /// - Parameter url: value from `links.operation` for charge operation
    init(from url: URL, body: Body) {
        self.url = url
        self.chargeBody = body
    }
}

@available(iOS 14.0, *)
extension Charge {
    func logRequest(to logger: Logger) {
        logger.notice("[POST] ➡️ Charge request: \(url.absoluteString, privacy: .private)")
    }

    func logResponse(_ response: OperationResult, to logger: Logger) {
        logger.info("[POST] ✅ \(response.resultInfo, privacy: .private). Interaction: \(response.interaction.code, privacy: .private)/\(response.interaction.reason, privacy: .private)")
    }
}

// MARK: - Body

extension Charge {
    struct Body: Encodable {
        var account = [String: String]()
        var autoRegistration: Bool?
        var allowRecurrence: Bool?
        let browserData: BrowserData

        init(account: [String: String], autoRegistration: Bool?, allowRecurrence: Bool?) {
            self.account = account
            self.autoRegistration = autoRegistration
            self.allowRecurrence = allowRecurrence
            self.browserData = BrowserDataBuilder.build()
        }
    }
}
