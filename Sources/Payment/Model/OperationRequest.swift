// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

public class OperationRequest: NSObject {
    public init(networkInformation: NetworkInformation, form: Form?, riskData: [ProviderParameters]?) {
        self.networkInformation = networkInformation
        self.form = form
        self.riskData = riskData
    }

    public let networkInformation: NetworkInformation
    public let form: Form?
    public let riskData: [ProviderParameters]?
}
