// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

struct Card {
    /// Number without spaces
    var number: String?

    /// Date without formatting, e.g.: `1030`
    var expiryDate: String?

    var verificationCode: String?
    var holderName: String?

    /// Fill collection view with input fields with card's data.
    /// - Parameters:
    ///   - collectionView: collection view with input fields
    ///   - shouldSubmit: click the submit button (like `Pay` or `Save`) upon filling
    func fill(in collectionView: XCUIElementQuery) {
        tapAndType(text: number, in: collectionView.textFields["Card Number"])
        tapAndType(text: expiryDate, in: collectionView.textFields["MM / YY"])
        tapAndType(text: verificationCode, in: collectionView.textFields["CVV"])
        tapAndType(text: holderName, in: collectionView.textFields["Name on card"])
    }

    /// Fill and submit a payment with card's data.
    func submit(in collectionView: XCUIElementQuery) {
        fill(in: collectionView)
        collectionView.buttons.firstMatch.tap()
    }

    private func tapAndType(text: String?, in textField: XCUIElement) {
        guard let text = text else { return }

        XCTAssertTrue(textField.exists)
        textField.tap()
        textField.typeText(text)
    }
}

// MARK: - Predefined cards

extension Card {
    static var visa: Card = {
        .init(number: "4111111111111111",
              expiryDate: "1030",
              verificationCode: "111",
              holderName: "Test Test")
    }()
}
