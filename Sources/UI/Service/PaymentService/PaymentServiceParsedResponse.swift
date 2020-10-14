import Foundation

enum PaymentServiceParsedResponse {
    case result(Result<OperationResult, ErrorInfo>)
    case redirect(URL)
}
