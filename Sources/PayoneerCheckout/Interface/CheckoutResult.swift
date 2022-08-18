// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

/// An object containing relevant information about the result of a checkout operation.
public struct CheckoutResult {
    public let operationResult: OperationResult?
    public let errorInfo: ErrorInfo?

    /// Contains value if something went wrong inside framework. In the most cases it would contain the `InternalError` type.
    public let cause: Error?

    /// Contains result info from `OperationResult` or `ErrorInfo`.
    public let resultInfo: String

    /// A reference to `Interaction` object inside `operationResult` or `errorInfo`.
    public let interaction: Interaction

    init(result: Result<OperationResult, ErrorInfo>) {
        switch result {
        case .success(let operationResult):
            self.operationResult = operationResult
            self.errorInfo = nil
            self.cause = nil
            self.resultInfo = operationResult.resultInfo
            self.interaction = operationResult.interaction
        case .failure(let errorInfo):
            self.operationResult = nil
            self.errorInfo = errorInfo
            self.cause = (errorInfo as? CustomErrorInfo)?.underlyingError
            self.resultInfo = errorInfo.resultInfo
            self.interaction = errorInfo.interaction
        }
    }
}
