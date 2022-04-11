// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// An object containing relevant information about the result of a checkout operation.
public class CheckoutResult: NSObject {
    public var operationResult: OperationResult? {
        guard case let .success(unwrappedOperationResult) = result else {
            return nil
        }

        return unwrappedOperationResult
    }

    public var errorInfo: ErrorInfo? {
        guard case let .failure(error) = result else {
            return nil
        }

        return error
    }

    /// Contains value if something went wrong inside framework. In the most cases it would contain `InternalError` type.
    public var cause: Error? {
        return (errorInfo as? CustomErrorInfo)?.underlyingError
    }

    /// Contains result info from `OperationResult` or `ErrorInfo`
    public var resultInfo: String { result.resultInfo }

    /// A reference to `Interaction` object inside `operationResult` or `errorInfo`.
    public var interaction: Interaction { result.interaction }

    // MARK: Internal

    private let result: Result<OperationResult, ErrorInfo>

    internal init(operationResult: Result<OperationResult, ErrorInfo>) {
        self.result = operationResult
    }
}
