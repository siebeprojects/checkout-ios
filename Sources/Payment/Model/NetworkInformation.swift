// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class NetworkInformation: NSObject {
    public init(networkCode: String, paymentMethod: String?, operationType: String, links: [String: URL]) {
        self.networkCode = networkCode
        self.paymentMethod = paymentMethod
        self.operationType = operationType
        self.links = links
    }

    public let networkCode: String
    public let paymentMethod: String?
    public let operationType: String
    public let links: [String: URL]
}
