// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import XCTest

struct Transaction: Codable {
    var integration: String?

    /// Identifier for this transaction given by the merchant. It is not validated for uniqueness by OPG, but may be checked for by some PSPs, thus recommended to be unique.
    var transactionId: String

    /// Country where the payment is originating. This influences the choice of the available payment networks. Value format is according to ISO 3166-1 (alpha-2), e.g. "DE", "FR", "US", "GB", etc.
    var country: String

    var callback: Callback
    var customer: Customer
    var payment: Payment

    var style: Style?

    /// Type of operation this `LIST` session is initialized for.
    ///
    /// **Default** type is `CHARGE` unless `operationType` is explicitly set or one of the legacy options is supplied during `LIST` initialization: `updateOnly`, `presetFirst`, or `preselection.direction`
    var operationType: String?

    var division: String?
}

extension Transaction {
    /// Load template transaction from JSON.
    /// - Parameter amount: you could specify a custom amount (used as "magic number" for testing).
    static func loadFromTemplate(amount: MagicNumber = .nonMagicNumber, operationType: OperationType = .charge) throws -> Transaction {
        let bundle = Bundle(for: PaymentSessionService.self)
        let url = bundle.url(forResource: "Transaction", withExtension: "json")!
        let data = try Data(contentsOf: url)

        let amount = try XCTUnwrap(amount.value(for: operationType), "Specified magic number is not supported for that operation type")

        var transaction = try JSONDecoder().decode(Transaction.self, from: data)
        transaction.payment.amount = amount
        transaction.operationType = operationType.rawValue

        return transaction
    }
}

extension Transaction {
    /// Numbers are taken from https://www.optile.io/opg#293524
    enum MagicNumber {
        case proceedOk
        case retry
        case tryOtherAccount
        case tryOtherNetwork
        case nonMagicNumber

        func value(for operationType: OperationType) -> Double? {
            switch operationType {
            case .charge: return chargeFlowValue
            case .update: return updateFlowValue
            }
        }

        private var chargeFlowValue: Double {
            switch self {
            case .proceedOk: return 1.01
            case .retry: return 1.03
            case .tryOtherNetwork: return 1.20
            case .tryOtherAccount: return 1.21
            case .nonMagicNumber: return 15
            }
        }

        private var updateFlowValue: Double? {
            switch self {
            case .proceedOk: return 1.01
            case .retry: return nil
            case .tryOtherNetwork: return nil
            case .tryOtherAccount: return 1.21
            case .nonMagicNumber: return 15
            }
        }
    }

    enum OperationType: String {
        case charge = "CHARGE"
        case update = "UPDATE"
    }
}
