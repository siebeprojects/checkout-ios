// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

/// Builder responsible for creating URL for external redirects from `Redirect` object.
struct RedirectURLBuilder {
    let redirect: Redirect

    /// Links property from `OperationResult`
    let links: [String: URL]?

    /// Construct an url from `Redirect` object which should be opened in a browser to continue an operation request.
    func createRedirectURL() throws -> URL {
        switch redirect.method {
        case .GET:
            guard let components = URLComponents(url: redirect.url, resolvingAgainstBaseURL: false) else {
                throw RedirectURLBuilderError(errorDescription: "Redirect object contains invalid url")
            }

            return try create(from: components, replacingQueryItemsWith: redirect.parameters)
        case .POST:
            // For POST redirect we return it is `GET` redirects.
            guard let redirectURL = links?["redirect"] else {
                throw RedirectURLBuilderError(errorDescription: "OperationResult links doesn't contain redirect property which is mandatory if redirect method is POST")
            }

            return redirectURL
        }
    }

    private func create(from inputComponents: URLComponents, replacingQueryItemsWith parameters: [Parameter]?) throws -> URL {
        var components = inputComponents

        // Add or replace query items with parameters from `Redirect` object
        if let parameters = parameters, !parameters.isEmpty {
            var queryItems = components.queryItems ?? [URLQueryItem]()

            queryItems += parameters.map {
                URLQueryItem(name: $0.name, value: $0.value)
            }

            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw RedirectURLBuilderError(errorDescription: "Unable to build redirect URL from components")
        }

        return url
    }
}

private struct RedirectURLBuilderError: LocalizedError {
    var errorDescription: String?
}
