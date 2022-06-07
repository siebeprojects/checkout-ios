// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import os.log

@available(iOS 14.0, *)
public extension Error {
    func log(to logger: Logger, level: OSLogType = .error) {
        var text = String()
        dump(self, to: &text)
        logger.log(level: level, "\(text)")
    }
}
