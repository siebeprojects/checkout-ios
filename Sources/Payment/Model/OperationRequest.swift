// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

public protocol OperationRequest {
    var operationType: String { get }
    func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void))
}

public struct PaymentRequest: OperationRequest {
    /// Payment network code.
    let networkCode: String
    let operationURL: URL
    var inputFields: [String: String] = [:]
    var autoRegistration: Bool?
    var allowRecurrence: Bool?
    public let operationType: String
    var providerRequest: ProviderParameters?
    let providerRequests: [ProviderParameters]?

    public init(networkCode: String, operationURL: URL, inputFields: [String : String] = [:], autoRegistration: Bool? = nil, allowRecurrence: Bool? = nil, operationType: String, providerRequest: ProviderParameters? = nil, providerRequests: [ProviderParameters]?) {
        self.networkCode = networkCode
        self.operationURL = operationURL
        self.inputFields = inputFields
        self.autoRegistration = autoRegistration
        self.allowRecurrence = allowRecurrence
        self.operationType = operationType
        self.providerRequest = providerRequest
        self.providerRequests = providerRequests
    }

    public func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        let chargeRequestBody = NetworkRequest.Operation.Body(account: inputFields, autoRegistration: autoRegistration, allowRecurrence: allowRecurrence, providerRequest: providerRequest, providerRequests: providerRequests)
        let chargeRequest = NetworkRequest.Operation(from: operationURL, body: chargeRequestBody)
        let chargeOperation = SendRequestOperation(connection: connection, request: chargeRequest)
        chargeOperation.downloadCompletionBlock = completion
        chargeOperation.start()
    }
}

public struct OnSelectRequest: OperationRequest {
    let operationURL: URL
    public let operationType: String
    let paymentRequest: PaymentRequest

    public init(operationURL: URL, operationType: String, paymentRequest: PaymentRequest) {
        self.operationURL = operationURL
        self.operationType = operationType
        self.paymentRequest = paymentRequest
    }

    public func send(using connection: Connection, completion: @escaping ((Result<OperationResult, Error>) -> Void)) {
        let onSelectRequest = NetworkRequest.OnSelectRequest(url: operationURL)
        let operation = SendRequestOperation(connection: connection, request: onSelectRequest)
        operation.downloadCompletionBlock = completion
        operation.start()
    }
}
