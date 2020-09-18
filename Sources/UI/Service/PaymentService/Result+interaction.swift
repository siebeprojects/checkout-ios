import Foundation

extension Result where Success: OperationResult, Failure: ErrorInfo {
    var interaction: Interaction {
        switch self {
        case .success(let operationResult): return operationResult.interaction
        case .failure(let errorInfo): return errorInfo.interaction
        }
    }
}
