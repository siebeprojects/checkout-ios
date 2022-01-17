// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com/
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

enum ExpirationDateValidatorError: Error {
    case invalidInput
    case failedToCreateDateFromString
}

struct ExpirationDateValidator {
    let month: Int?
    let year: Int?

    var isExpired: Bool {
        get throws {
            guard let month = month, let year = year else { throw ExpirationDateValidatorError.invalidInput }

            let dateFormatter = DateFormatter()
            dateFormatter.twoDigitStartDate = Calendar.current.date(byAdding: .year, value: -30, to: Date())
            dateFormatter.dateFormat = "yy-MM"

            let expirationDateString = "\(String(year).suffix(2))-\(month)"

            guard let expirationDate = dateFormatter.date(from: expirationDateString) else {
                throw ExpirationDateValidatorError.failedToCreateDateFromString
            }

            return Calendar.current.compare(expirationDate, to: Date(), toGranularity: .month) == .orderedAscending
        }
    }
}
