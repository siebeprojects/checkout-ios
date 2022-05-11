// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

private struct RedirectResponseParserError: LocalizedError {
    var errorDescription: String?
}

/// A structure that parses `OperationResult` returned after an operation to get an optional redirect advice.
public struct RedirectResponseParser {
    let supportedRedirectTypes: [String]

    public init(supportedRedirectTypes: [String]) {
        self.supportedRedirectTypes = supportedRedirectTypes
    }

    /// Get redirection url from `OperationResult` object if there is any.
    ///
    /// Could throw an error if an error happens during the creation of redirect URL. In that case, the redirect should happen, but we couldn't create an URL because of the error.
    /// - Returns: url for redirection or `nil` if there is no redirection request in `OperationResult`
    public func getRedirect(from operationResult: OperationResult) throws -> URL? {
        guard
            let redirect = operationResult.redirect,
            let redirectType = redirect.type,
            supportedRedirectTypes.contains(redirectType)
        else {
            return nil
        }

        let urlBuilder = RedirectURLBuilder(redirect: redirect, links: operationResult.links)
        return try urlBuilder.createRedirectURL()
    }
}
