// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

struct Card: PaymentNetwork {
    var number: String
    var expiryDate: String
    var verificationCode: String
    var holderName: String
    var label: String

    var maskedLabel: String {
        "\(label) •••• \(number.suffix(4))"
    }

    static var visa: Card {
        Card(
            number: "4111111111111111",
            expiryDate: "1030",
            verificationCode: "111",
            holderName: "Test Test",
            label: "Visa"
        )
    }

    static var mastercard: Card {
        Card(
            number: "5555555555554444",
            expiryDate: "1030",
            verificationCode: "111",
            holderName: "Test Test",
            label: "MasterCard"
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
