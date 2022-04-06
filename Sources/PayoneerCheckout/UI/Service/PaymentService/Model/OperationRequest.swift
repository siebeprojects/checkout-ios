// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

protocol OperationRequest {
    var operationType: String { get }

    func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void))
}
