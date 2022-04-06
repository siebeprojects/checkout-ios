// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

public class ProviderParameters: NSObject, Codable {
    /// The code of payment provider
    public let providerCode: String

    /// The type of provider
    public let providerType: String?

    /// An array of parameters
    public let parameters: [Parameter]?

    public init(providerCode: String, providerType: String?, parameters: [Parameter]?) {
        self.providerCode = providerCode
        self.providerType = providerType
        self.parameters = parameters
    }
}
