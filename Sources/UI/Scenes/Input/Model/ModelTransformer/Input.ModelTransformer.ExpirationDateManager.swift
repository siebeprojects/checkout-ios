// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input.ModelTransformer {
    struct ExpirationDateManager {
        let expiryMonthElementName = "expiryMonth"
        let expiryYearElementName = "expiryYear"
    }
}

extension Input.ModelTransformer.ExpirationDateManager {
    struct RemovalResult {
        let fieldsWithoutDateElements: [InputField & CellRepresentable]
        let removedIndexes: [Int]

        /// Both expiration year and month were present
        let hadExpirationDate: Bool
    }
}

extension Input.ModelTransformer.ExpirationDateManager {
    func removeExpiryFields(in inputFields: [InputField & CellRepresentable]) -> RemovalResult {
        var hasExpiryYear = false
        var hasExpiryMonth = false
        var fieldsWithoutDateElements = [InputField & CellRepresentable]()
        var removedIndexes = [Int]()

        for inputElement in inputFields.enumerated() {
            switch inputElement.element.id {
            case .inputElementName(expiryMonthElementName):
                hasExpiryMonth = true
                removedIndexes.append(inputElement.offset)
            case .inputElementName(expiryYearElementName):
                hasExpiryYear = true
                removedIndexes.append(inputElement.offset)
            default:
                fieldsWithoutDateElements.append(inputElement.element)
            }
        }

        return .init(
            fieldsWithoutDateElements: fieldsWithoutDateElements,
            removedIndexes: removedIndexes,
            hadExpirationDate: hasExpiryMonth && hasExpiryYear
        )
    }
}
