// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import XCTest

struct ListSettings: Codable {
    let integration: String
    let transactionId: String
    let country: String
    let callback: Callback
    let customer: Customer
    let payment: Payment
    let style: Style
    let operationType: String
    let allowDelete: Bool?
    let division: String?
    let checkoutConfigurationName: String?

    init(
        magicNumber: ListSettings.MagicNumber = .nonMagicNumber,
        operationType: ListSettings.OperationType = .charge,
        division: String? = nil,
        checkoutConfiguration: CheckoutConfiguration? = nil,
        allowDelete: Bool? = nil,
        customerId: String? = nil
    ) throws {
        let template = try ListSettings.createFromTemplate()

        let amount = try XCTUnwrap(magicNumber.value(for: operationType), "Specified magic number is not supported for that operation type")

        self.integration = template.integration
        self.transactionId = String(Date().timeIntervalSince1970)
        self.country = template.country
        self.callback = template.callback
        self.payment = Payment(reference: template.payment.reference, amount: amount, currency: template.payment.currency)
        self.style = template.style
        self.operationType = operationType.rawValue
        self.allowDelete = allowDelete
        self.division = division
        self.checkoutConfigurationName = checkoutConfiguration?.name

        if let customerId = customerId {
            self.customer = Customer(number: template.customer.number, email: template.customer.email, registration: Registration(id: customerId))
        } else {
            self.customer = template.customer
        }
    }

    private static func createFromTemplate() throws -> ListSettings {
        let bundle = Bundle(for: NetworksTests.self)
        let url = bundle.url(forResource: "ListSettings", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ListSettings.self, from: data)
    }
}

// MARK: - OperationType

extension ListSettings {
    enum OperationType: String {
        case charge = "CHARGE"
        case update = "UPDATE"
        case preset = "PRESET"
    }
}

// MARK: - Magic numbers

extension ListSettings {
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
        case forceFail

        /// Get the amount value for the magic number.
        ///
        /// Each operation type may have different amount for the same magic number.
        func value(for operationType: ListSettings.OperationType) -> Double? {
            switch operationType {
            case .charge: return chargeFlowValue
            case .update: return updateFlowValue
            case .preset: return presetFlowValue
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
            case .forceFail:       return 8.27
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
            case .forceFail:       return 8.27
            }
        }

        private var presetFlowValue: Double? {
            switch self {
            case .proceedOK:       return 1.01
            case .threeDS2:        return 1.23
            case .nonMagicNumber:  return 15
            default: return nil
            }
        }
    }
}
