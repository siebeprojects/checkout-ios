// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Error returned from a server
open class ErrorInfo: NSObject, Error, Decodable {
    public let resultInfo: String
    public let interaction: Interaction

    var localizedDescription: String {
        resultInfo
    }

    /// - Note: Use `CustomErrorInfo` instead of that class when creating custom error info
    public init(resultInfo: String, interaction: Interaction) {
        self.resultInfo = resultInfo
        self.interaction = interaction
    }
}
