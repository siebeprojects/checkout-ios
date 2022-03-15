// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import os.log

// MARK: - Request

extension NetworkRequest {
    struct OnSelectRequest: PostRequest {
        var url: URL
        let body: EmptyObject? = EmptyObject()
        let queryItems: [URLQueryItem] = []

        typealias Response = OperationResult

        /// - Parameter url: `self` link from payment session
        init(url: URL) {
            self.url = url
        }
    }
}

extension NetworkRequest.OnSelectRequest {
    struct EmptyObject: Encodable {
        fileprivate init() {}
    }
}


@available(iOS 14.0, *)
extension NetworkRequest.OnSelectRequest {
    func logRequest(to logger: Logger) {
        logger.notice("[POST] ➡️ OnSelect call")
    }

    func logResponse(_ response: OperationResult, to logger: Logger) {
        logger.notice("[POST] ✅ \(response.resultInfo, privacy: .private)")
    }
}
