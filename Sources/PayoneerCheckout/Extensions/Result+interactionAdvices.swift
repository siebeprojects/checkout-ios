// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

extension Result where Success: OperationResult, Failure: ErrorInfo {
    var interaction: Interaction {
        switch self {
        case .success(let operationResult): return operationResult.interaction
        case .failure(let errorInfo): return errorInfo.interaction
        }
    }

    /// Descriptive information that complements the interaction advice.
    var resultInfo: String {
        switch self {
        case .success(let operationResult): return operationResult.resultInfo
        case .failure(let errorInfo): return errorInfo.resultInfo
        }
    }
}
