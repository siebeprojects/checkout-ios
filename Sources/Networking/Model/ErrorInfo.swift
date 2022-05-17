// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Error returned from a server
@objc open class ErrorInfo: NSObject, Decodable {
    @objc public let resultInfo: String
    @objc public let interaction: Interaction

    /// - Note: Use `CustomErrorInfo` instead of that class when creating custom error info
    public init(resultInfo: String, interaction: Interaction) {
        self.resultInfo = resultInfo
        self.interaction = interaction
    }
}

extension ErrorInfo: Error {
    var localizedDescription: String { return resultInfo }
}
