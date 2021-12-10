// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

// MARK: - Request

/// Request for `CHARGE` operation.
struct Charge {
    let url: URL
    var body: Body
}

// MARK: - Body

extension Charge {
    struct Body: Encodable {
        var account = [String: String]()
        var autoRegistration: Bool?
        var allowRecurrence: Bool?
    }
    
    struct Response: Decodable {
        let interaction: Interaction
        let redirect: Redirect?
    }
}
