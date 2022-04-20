// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

enum ExpirationDateFormatterError: Error {
    case invalidInput
}

struct ExpirationDateFormatter {
    let month: Int?
    let year: Int?

    var text: String {
        get throws {
            guard let month = month, let year = year else { throw ExpirationDateFormatterError.invalidInput }
            return String(format: "%02d", month) + " / " + String(year).suffix(2)
        }
    }
}
