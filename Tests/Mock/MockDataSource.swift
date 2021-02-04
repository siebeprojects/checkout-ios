// Copyright (c) 2020–2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

protocol MockDataSource {
    func fakeData(for request: URLRequest) -> Result<Data?, Error>
}

extension String: MockDataSource {
    func fakeData(for request: URLRequest) -> Result<Data?, Error> {
        return .success(self.data(using: .isoLatin1)!)
    }
}

extension Data: MockDataSource {
    func fakeData(for request: URLRequest) -> Result<Data?, Error> {
        return .success(self)
    }
}

extension TestError: MockDataSource {
    func fakeData(for request: URLRequest) -> Result<Data?, Error> {
        return .failure(self)
    }
}
