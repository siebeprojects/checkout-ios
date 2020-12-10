// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Result where Success: OperationResult, Failure: ErrorInfo {
    var interaction: Interaction {
        switch self {
        case .success(let operationResult): return operationResult.interaction
        case .failure(let errorInfo): return errorInfo.interaction
        }
    }

    var errorInfo: ErrorInfo {
        switch self {
        case .success(let operationResult): return ErrorInfo(resultInfo: operationResult.resultInfo, interaction: operationResult.interaction)
        case .failure(let errorInfo): return errorInfo
        }
    }
    
    var resultInfo: String {
        switch self {
        case .success(let operationResult): return operationResult.resultInfo
        case .failure(let errorInfo): return errorInfo.resultInfo
        }
    }
}
