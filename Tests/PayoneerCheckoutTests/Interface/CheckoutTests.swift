// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import PayoneerCheckout

private let customAccentColor: UIColor = .blue

final class CheckoutTests: XCTestCase {
    private var checkout: Checkout!

    override func setUp() {
        super.setUp()

        let appearance = CheckoutAppearance(
            primaryTextColor: .black,
            secondaryTextColor: .black,
            backgroundColor: .black,
            accentColor: customAccentColor,
            errorColor: .black,
            borderColor: .black,
            buttonTitleColor: .black
        )

        let configuration = CheckoutConfiguration(
            listURL: URL(string: "/")!,
            appearance: appearance,
            riskProviders: []
        )

        checkout = Checkout(configuration: configuration)
    }

    override func tearDown() {
        CheckoutAppearance.shared = nil
        checkout = nil

        super.tearDown()
    }

    func testInit_shouldStartAppearanceSingleton() {
        XCTAssertTrue(CheckoutAppearance.shared != nil)
    }

    func testPresentPayment_shouldSetPresenter() {
        let presenter = MockPresenter()
        checkout.presentPaymentList(from: presenter, completion: { _ in })
        XCTAssertEqual(checkout.presenter, presenter)
    }

    func testPresentPayment_shouldSetCompletionBlock() {
        checkout.presentPaymentList(from: MockPresenter(), completion: { _ in })
        XCTAssertTrue(checkout.paymentCompletionBlock != nil)
    }

    func testPresentPayment_shouldSetPaymentListViewController() {
        checkout.presentPaymentList(from: MockPresenter(), completion: { _ in })
        XCTAssertTrue(checkout.paymentListViewController != nil)
    }

    func testPresentPayment_whenSubsequentCall_shouldCallDismiss() {
        let firstPresenter = MockPresenter()
        checkout.presentPaymentList(from: firstPresenter, completion: { _ in })
        checkout.presentPaymentList(from: MockPresenter(), completion: { _ in })
        XCTAssertTrue(firstPresenter.dismissCalled)
    }

    func testPresentPayment_shouldPresentNavigationController() {
        let presenter = MockPresenter()
        checkout.presentPaymentList(from: presenter, completion: { _ in })
        XCTAssertEqual(presenter.presented, checkout.paymentListViewController?.navigationController)
    }

    func testPresentPayment_whenCustomAccentColor_shouldSetTintColor() {
        checkout.presentPaymentList(from: MockPresenter(), completion: { _ in })
        XCTAssertEqual(checkout.paymentListViewController?.navigationController?.view.tintColor, customAccentColor)
    }
}
