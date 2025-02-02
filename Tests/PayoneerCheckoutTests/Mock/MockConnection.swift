// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
@testable import PayoneerCheckout
import Networking

class MockConnection: Connection {
    private let serialQueue = DispatchQueue(label: "Mock connection serial queue")
    private(set) var requestedURL: URL?
    let dataSource: MockDataSource

    init(dataSource: MockDataSource) {
        self.dataSource = dataSource
    }

    func send(request: URLRequest, completionHandler: @escaping ((Result<Data, Error>) -> Void)) {
        serialQueue.sync(flags: .barrier) {
            self.requestedURL = request.url!
        }

        switch dataSource.fakeData(for: request) {
        case .success(let data):
            completionHandler(.success(data))
        case .failure(let error):
            completionHandler(.failure(error))
        }
    }

    func cancel() {}

    static func isRecoverableError(_ error: Error) -> Bool {
        return false
    }
}
