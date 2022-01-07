// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

struct Visa: PaymentNetwork {
    let number: String
    let expiryDate: String
    let verificationCode: String
    let holderName: String

    let label: String = "Visa"
    let maskedLabel: String = "Visa •••• 1111"

    /// Initializes a card with optional, overridable values.
    /// - Parameters:
    ///   - number: The card number without formatting.
    ///   - expiryDate: The expiration month and year without formatting (e.g. 1030).
    ///   - verificationCode: The CVV.
    ///   - holderName: The name on the card.
    init(
        number: String = "4111111111111111",
        expiryDate: String = "1030",
        verificationCode: String = "111",
        holderName: String = "Test Test"
    ) {
        self.number = number
        self.expiryDate = expiryDate
        self.verificationCode = verificationCode
        self.holderName = holderName
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
