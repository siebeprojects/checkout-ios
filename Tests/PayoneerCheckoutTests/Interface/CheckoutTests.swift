// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
import SafariServices
@testable import PayoneerCheckout
import Networking

private let customAccentColor: UIColor = .blue

final class CheckoutTests: XCTestCase {
    private var mockChargePresetService: MockChargePresetService!
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

        mockChargePresetService = MockChargePresetService()

        checkout = Checkout(configuration: configuration, chargePresetService: mockChargePresetService)
    }

    override func tearDown() {
        mockChargePresetService = nil
        checkout = nil

        super.tearDown()
    }

    func testInit_shouldSetAppearanceSingleton() {
        XCTAssertTrue(CheckoutAppearance.shared == checkout.configuration.appearance)
    }

    func testPresentPayment_shouldSetPresenter() {
        let presenter = MockCheckoutPresenter()
        checkout.presentPaymentList(from: presenter, completion: { _ in })
        XCTAssertEqual(checkout.presenter, presenter)
    }

    func testPresentPayment_shouldSetCompletionBlock() {
        checkout.presentPaymentList(from: MockCheckoutPresenter(), completion: { _ in })
        XCTAssertTrue(checkout.paymentCompletionBlock != nil)
    }

    func testPresentPayment_shouldSetPaymentListViewController() {
        checkout.presentPaymentList(from: MockCheckoutPresenter(), completion: { _ in })
        XCTAssertTrue(checkout.paymentListViewController != nil)
    }

    func testPresentPayment_shouldPresentNavigationController() {
        let presenter = MockCheckoutPresenter()
        checkout.presentPaymentList(from: presenter, completion: { _ in })
        XCTAssertEqual(presenter.presented, checkout.paymentListViewController?.navigationController)
    }

    func testPresentPayment_whenCustomAccentColor_shouldSetTintColor() {
        checkout.presentPaymentList(from: MockCheckoutPresenter(), completion: { _ in })
        XCTAssertEqual(checkout.paymentListViewController?.navigationController?.view.tintColor, customAccentColor)
    }

    func testChargePresetAccount_whenCompletion_shouldCallDismiss() {
        mockChargePresetService.result = .completion

        let presenter = MockCheckoutPresenter()
        checkout.chargePresetAccount(presenter: presenter, completion: { _ in })
        XCTAssertTrue(presenter.dismissCalled)
    }

    func testChargePresetAccount_whenCompletion_shouldCallCompletion() {
        mockChargePresetService.result = .completion

        var completionCalled = false
        checkout.chargePresetAccount(presenter: MockCheckoutPresenter(), completion: { _ in completionCalled = true })
        XCTAssertTrue(completionCalled)
    }

    func testChargePresetAccount_whenAuthenticationChallenge_shouldCallPresent() {
        mockChargePresetService.result = .authenticationChallenge

        let presenter = MockCheckoutPresenter()
        checkout.chargePresetAccount(presenter: presenter, completion: { _ in })
        XCTAssertTrue(presenter.presentCalled)
    }

    func testDismiss_shouldCallCompletion() {
        var completionCalled = false
        let completion = { completionCalled = true }
        checkout.dismiss(completion)
        XCTAssertTrue(completionCalled)
    }

    func testDismiss_shouldCallPresenterDismiss() {
        let firstPresenter = MockCheckoutPresenter()
        checkout.presentPaymentList(from: firstPresenter, completion: { _ in })
        checkout.dismiss()
        XCTAssertTrue(firstPresenter.dismissCalled)
    }

    func testPaymentServiceDidReceiveResult_shouldCallDismiss() {
        let presenter = MockCheckoutPresenter()
        checkout.presentPaymentList(from: presenter, completion: { _ in })
        checkout.paymentService(didReceiveResult: CheckoutResult(operationResult: .failure(ErrorInfo(resultInfo: "", interaction: Interaction(code: "", reason: "")))))
        XCTAssertTrue(presenter.dismissCalled)
    }

    func testPaymentServiceDidReceiveResult_shouldCallCompletionBlock() {
        var completionCalled = false
        checkout.presentPaymentList(from: MockCheckoutPresenter(), completion: { _ in completionCalled = true })
        checkout.paymentService(didReceiveResult: CheckoutResult(operationResult: .failure(ErrorInfo(resultInfo: "", interaction: Interaction(code: "", reason: "")))))
        XCTAssertTrue(completionCalled)
    }

    func testPaymentServiceDidReceiveResult_shouldNullifyCompletionBlock() {
        checkout.presentPaymentList(from: MockCheckoutPresenter(), completion: { _ in })
        checkout.paymentService(didReceiveResult: CheckoutResult(operationResult: .failure(ErrorInfo(resultInfo: "", interaction: Interaction(code: "", reason: "")))))
        XCTAssertNil(checkout.paymentCompletionBlock)
    }
}
