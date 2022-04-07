// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import XCTest

class PaymentService {
    private let networkService = NetworkService()

    func registerCustomer(card: Card) throws -> String {
        try XCTContext.runActivity(named: "Register the new customer") { _ in
            let session = try NetworksTests.createPaymentSession(using: Transaction(operationType: .charge))
            let operationURL = session.networks.applicable[0].links!["operation"]!
            return try registerCustomer(usingOperationURL: operationURL, card: card)
        }
    }
    
    private func registerCustomer(usingOperationURL operationURL: URL, card: Card) throws -> String {
        var registerCustomerResult: Result<String, Error>?
        let semaphore = DispatchSemaphore(value: 0)
        registerCustomer(using: operationURL, card: card) { result in
            registerCustomerResult = result
            semaphore.signal()
        }

        let timeoutResult = semaphore.wait(timeout: .now() + .networkTimeout)

        guard case .success = timeoutResult else {
            throw "Timeout waiting for charge request reply. Most likely it's a network timeout error."
        }

        switch registerCustomerResult {
        case .success(let customerId): return customerId
        case .failure(let error): throw error
        case .none: throw "Register customer result wasn't set"
        }
    }

    private func registerCustomer(using operationURL: URL, card: Card, completion: @escaping ((Result<String, Error>) -> Void)) {
        var request = URLRequest(url: operationURL)
        request.httpMethod = "POST"

        do {
            request.httpBody = try createBodyForChargeRequest(card: card)
        } catch {
            completion(.failure(error))
            return
        }

        networkService.send(request: request) { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure("Server's reply doesn't contain data"))
                    return
                }

                do {
                    let customerId = try self.getCustomerId(fromChargeResponse: data)
                    completion(.success(customerId))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func createBodyForChargeRequest(card: Card) throws -> Data {
        let account: [String: String] = [
            "number": card.number,
            "expiryMonth": String(card.expiryDate.prefix(2)),
            "expiryYear": String(card.expiryDate.suffix(2)),
            "verificationCode": card.verificationCode,
            "holderName": card.holderName
        ]

        let body = Charge.Body(account: account, autoRegistration: true, allowRecurrence: false)
        return try JSONEncoder().encode(body)
    }

    private func getCustomerId(fromChargeResponse data: Data) throws -> String {
        let response = try JSONDecoder().decode(Charge.Response.self, from: data)

        guard let parameters = response.redirect?.parameters else {
            throw "There is no redirect or redirect.parameters properties in charge's response"
        }

        guard let customerRegistrationParameter = parameters["customerRegistrationId"] else {
            throw "There is no customerRegistrationId parameter inside Redirect object"
        }

        return customerRegistrationParameter.value!
    }
}

private extension Array where Self.Element == Parameter {
    subscript(name: String) -> Parameter? {
        get {
            return self.first(where: { $0.name == name })
        }
    }
}
