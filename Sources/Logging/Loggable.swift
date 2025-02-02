// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import os.log

private let subsystem = "com.payoneer.checkout"

public protocol Loggable {
    var logCategory: String { get }

    @available(iOS 14.0, *)
    var logger: Logger { get }
}

public extension Loggable {
    var logCategory: String { String(describing: Self.self) }

    @available(iOS 14.0, *)
    var logger: Logger {
        Logger(subsystem: subsystem, category: logCategory)
    }
}
