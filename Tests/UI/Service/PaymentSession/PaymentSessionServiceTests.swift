// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Optile

class PaymentSessionServiceTests: XCTestCase {
    // TODO:
    // Write a test if payment network doesn't contain language URL or download failed

    func testValid() {
        let result = syncLoadPaymentSession(using: PaymentSessionDataSource())

        switch result {
        case .success(let session):
            XCTAssertEqual(session.networks.count, 5)
            XCTAssertEqual(session.networks[1].label, "Diners Club Localized")
        case .failure(let error): XCTFail(error)
        case .loading: XCTFail("Shouldn't be loading")
        }
    }

    // May detect async crash because we running concurrently a lot of tasks
    func testThreadingCrashes() {
        for _ in 1...20 {
            testValid()
        }
    }

    // MARK: - Helper methods

    private func syncLoadPaymentSession(using dataSource: MockDataSource) -> Load<PaymentSession, Error> {
        let connection = MockConnection(dataSource: dataSource)
        let provider = PaymentSessionService(paymentSessionURL: URL.example, connection: connection, localizationProvider: SharedTranslationProvider())

        let loadingPromise = expectation(description: "PaymentSessionProvider: loading")
        let resultPromise = expectation(description: "PaymentSessionProvider: completed")
        var sessionResult: Load<PaymentSession, Error>!
        provider.loadPaymentSession(
            loadDidComplete: { result in
                switch result {
                case .loading: loadingPromise.fulfill()
                default:
                    sessionResult = result
                    resultPromise.fulfill()
                }
            },
            shouldSelect: { _ in
                return
            }
        )
        wait(for: [loadingPromise, resultPromise], timeout: 1, enforceOrder: true)

        let attachment = XCTAttachment(subject: sessionResult)
        attachment.name = "LoadPaymentSessionResult"
        add(attachment)

        return sessionResult
    }
}

// MARK: - Data Sources

// swiftlint:disable identifier_name

private class PaymentPageFailureDataSource: MockDataSource {
    func fakeData(for request: URLRequest) -> Result<Data?, Error> {
        guard let path = request.url?.path else {
            let error = TestError(description: "Request doesn't contain URL")
            XCTFail(error)
            return .failure(error)
        }

        switch path {
        case "":
            return MockFactory.ListResult.listResultData.fakeData(for: request)
        case let s where s.contains("checkout.json"):
            let error = TestError(description: "No payment page localization")
            return .failure(error)
        default:
            let error = TestError(description: "Unexpected URL was requested")
            XCTFail(error)
            return .failure(error)
        }
    }
}

private class PaymentSessionDataSource: MockDataSource {
    func fakeData(for request: URLRequest) -> Result<Data?, Error> {
        guard let path = request.url?.path else {
            let error = TestError(description: "Request doesn't contain URL")
            XCTFail(error)
            return .failure(error)
        }

        switch path {
        case "":
            return MockFactory.ListResult.listResultData.fakeData(for: request)
        case let s where s.contains("checkout.json"):
            return MockFactory.Localization.paymentPage.fakeData(for: request)
        case let s where s.contains(".json"):
            return MockFactory.Localization.paymentNetwork.fakeData(for: request)
        default:
            let error = TestError(description: "Unexpected URL was requested")
            XCTFail(error)
            return .failure(error)
        }
    }
}
