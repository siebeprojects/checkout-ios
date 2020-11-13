// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest
@testable import Optile

final class NetworkTests: XCTestCase {
    func testGetListResult() {
        let getListResultRequest = GetListResult(url: URL.example)
        let connection = MockConnection(dataSource: MockFactory.ListResult.listResult)

        let promise = expectation(description: "SendRequestOperation completed")

        let sendOperation = SendRequestOperation(connection: connection, request: getListResultRequest)
        sendOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let listResult):
                XCTAssertEqual(listResult.networks.applicable.first?.code, "VISAELECTRON")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            promise.fulfill()
        }
        sendOperation.start()

        wait(for: [promise], timeout: 1)
    }

    static var allTests = [
        ("testGetListResult", testGetListResult)
    ]
}
