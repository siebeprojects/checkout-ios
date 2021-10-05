// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct TransactionSettings {
    let magicNumber: Transaction.MagicNumber
    let operationType: Transaction.OperationType
    let division: String?
    let checkoutConfiguration: CheckoutConfiguration?
    let allowDelete: Bool?

    init(
        magicNumber: Transaction.MagicNumber = .nonMagicNumber,
        operationType: Transaction.OperationType = .charge,
        division: String? = nil,
        checkoutConfiguration: CheckoutConfiguration? = nil,
        allowDelete: Bool? = nil
    ) {
        self.magicNumber = magicNumber
        self.operationType = operationType
        self.division = division
        self.checkoutConfiguration = checkoutConfiguration
        self.allowDelete = allowDelete
    }
}
