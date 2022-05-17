// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Payment
import Networking

public class RedirectControllerTests: XCTestCase {
    func testSafariManualDismiss() throws {
        let notification = NSNotification.Name("testNotification")
        let controller = RedirectController(openAppWithURLNotificationName: notification)

        var redirectResult: Result<OperationResult, Error>?
        let safariVC = controller.createSafariController(presentingURL: URL(string: "https://example.com")!) {
            redirectResult = $0
        }
        controller.safariViewControllerDidFinish(safariVC)

        switch redirectResult {
        case .failure(let error):
            guard let redirectError = error as? RedirectError else { fallthrough }
            XCTAssertEqual(redirectError, .missingOperationResult)
        default:
            XCTFail("Unexpected result received")
        }
    }

    func testOperationResultReceived() {
        let notification = NSNotification.Name("testNotification")
        let controller = RedirectController(openAppWithURLNotificationName: notification)

        var redirectResult: Result<OperationResult, Error>?
        let _ = controller.createSafariController(presentingURL: URL(string: "https://example.com")!) {
            redirectResult = $0
        }

        let okProceedRedirectURL = URL(string: "com.payoneer.checkout.examplecheckout.mobileredirect://?redirectType=RETURN&appId=com.payoneer.checkout.examplecheckout&shortId=17589-24004&customerRegistrationId=61e70c28aaac2d189203fc8eu&interactionReason=OK&resultCode=00000.TESTPSP.000&longId=627cdd5ace05d65c1f3da26cc&transactionId=tr1&interactionCode=PROCEED&amount=1.23&reference=Example+iOS+SDK&currency=EUR&notificationId=768048323366255&referenceId=627cdd5ace05d65c1f3da26cc&timestamp=2022-05-12T12%3A11%3A44.487%2B02%3A00")

        NotificationCenter.default.post(name: notification, object: okProceedRedirectURL, userInfo: nil)

        switch redirectResult {
        case .success(let operationResult):
            XCTAssertEqual(operationResult.interaction.reason, "OK")
            XCTAssertEqual(operationResult.interaction.code, "PROCEED")
        default:
            XCTFail("Unexpected result received")
        }
    }
}
