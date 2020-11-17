// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

@objc public class PaymentRequest: NSObject {
    /// Payment network code.
    public let networkCode: String

    public let operationURL: URL

    /// Textual dictionary with input fields.
    public let inputFields: [String: String]

    internal init(networkCode: String, operationURL: URL, inputFields: [String: String]) {
        self.networkCode = networkCode
        self.operationURL = operationURL
        self.inputFields = inputFields

        super.init()
    }
}
