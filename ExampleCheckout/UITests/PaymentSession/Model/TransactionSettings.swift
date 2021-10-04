//
//  TransactionSettings.swift
//  UITests
//
//  Created by Caio Araujo on 04.10.21.
//  Copyright © 2021 Payoneer Germany GmbH. All rights reserved.
//

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
