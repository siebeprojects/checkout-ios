// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Simple request that just performs `POST` request on specified URL.
/// - Note: `queryItems` will always override items from the `url`
protocol DeleteRequest: PostRequest {
    associatedtype Body

    var queryItems: [URLQueryItem] { get }
    var url: URL { get }
    var body: Body? { get }
    
    func encodeBody() throws -> Data?
}

extension DeleteRequest {
    var httpMethod: HTTPMethod { .DELETE }
}
