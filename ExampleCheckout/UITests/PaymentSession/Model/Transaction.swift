// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import XCTest

struct Transaction: Codable {
    let integration: String
    let transactionId: String
    let country: String
    let callback: Callback
    let customer: Customer
    let payment: Payment
    let style: Style
    let operationType: String
    let allowDelete: Bool?

    init(magicNumber: MagicNumber = .nonMagicNumber, operationType: OperationType = .charge, allowDelete: Bool? = nil) throws {
        let bundle = Bundle(for: NetworksTests.self)
        let url = bundle.url(forResource: "Transaction", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let template = try JSONDecoder().decode(Transaction.self, from: data)

        let amount = try XCTUnwrap(magicNumber.value(for: operationType), "Specified magic number is not supported for that operation type")

        self.integration = template.integration
        self.transactionId = String(Date().timeIntervalSince1970)
        self.country = template.country
        self.callback = template.callback
        self.customer = template.customer
        self.payment = Payment(reference: template.payment.reference, amount: amount, currency: template.payment.currency)
        self.style = template.style
        self.operationType = operationType.rawValue
        self.allowDelete = allowDelete
    }
}

// MARK: - OperationType

extension Transaction {
    enum OperationType: String {
        case charge = "CHARGE"
        case update = "UPDATE"
    }
}

// MARK: - Magic numbers

extension Transaction {
    /// The Payment Gateway enables you to test the "happy path" (a success is returned) as well as negative responses (e.g. denials). To test different cases you should use magic numbers as an amount value.
    ///
    /// Full list of magic numbers: https://www.optile.io/opg#293524
    enum MagicNumber {
        case proceedOK
        case proceedPending
        case retry
        case tryOtherAccount
        case tryOtherNetwork
        case nonMagicNumber
        case threeDS2

        /// Get the amount value for the magic number.
        ///
        /// Each operation type may have different amount for the same magic number.
        func value(for operationType: Transaction.OperationType) -> Double? {
            switch operationType {
            case .charge: return chargeFlowValue
            case .update: return updateFlowValue
            }
        }

        private var chargeFlowValue: Double {
            switch self {
            case .proceedOK:       return 1.01
            case .proceedPending:  return 1.04
            case .retry:           return 1.03
            case .tryOtherNetwork: return 1.20
            case .tryOtherAccount: return 1.21
            case .nonMagicNumber:  return 15
            case .threeDS2:        return 1.23
            }
        }

        private var updateFlowValue: Double? {
            switch self {
            case .proceedOK:       return 1.01
            case .proceedPending:  return 7.51
            case .retry:           return nil
            case .tryOtherNetwork: return nil
            case .tryOtherAccount: return 1.21
            case .nonMagicNumber:  return 15
            case .threeDS2:        return nil
            }
        }
    }
}
