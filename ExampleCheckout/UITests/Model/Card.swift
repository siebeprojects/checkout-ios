// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

struct Card: PaymentNetwork {
    let number: String
    let expiryDate: String
    let verificationCode: String
    let holderName: String
    let label: String
    let maskedLabel: String

    func overriding(number: String? = nil, expiryDate: String? = nil, verificationCode: String? = nil, holderName: String? = nil, label: String? = nil, maskedLabel: String? = nil) -> Card {
        Card(
            number: number ?? self.number,
            expiryDate: expiryDate ?? self.expiryDate,
            verificationCode: verificationCode ?? self.verificationCode,
            holderName: holderName ?? self.holderName,
            label: label ?? self.label,
            maskedLabel: maskedLabel ?? self.maskedLabel
        )
    }

    static var visa: Card {
        Card(
            number: "4111111111111111",
            expiryDate: "1030",
            verificationCode: "111",
            holderName: "Test Test",
            label: "Visa",
            maskedLabel: "Visa •••• 1111"
        )
    }

    static var mastercard: Card {
        Card(
            number: "5555555555554444",
            expiryDate: "1030",
            verificationCode: "111",
            holderName: "Test Test",
            label: "MasterCard",
            maskedLabel: "MasterCard •••• 4444"
        )
    }

    func fill(in collectionView: XCUIElementQuery) {
        XCTContext.runActivity(named: "Fill VISA card's data") { _ in
            tapAndType(text: number, in: collectionView.textFields["13 to 19 digits"])
            tapAndType(text: expiryDate, in: collectionView.textFields["MM / YY"])
            tapAndType(text: verificationCode, in: collectionView.textFields["3 digits"])
            tapAndType(text: holderName, in: collectionView.textFields["e.g. John Doe"])
        }
    }
}
