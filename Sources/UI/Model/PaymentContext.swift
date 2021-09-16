// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Global properties that may be useful but not directly related to applicable network or registered account.
class PaymentContext {
    let listOperationType: PaymentSession.Operation
    let extraElements: ExtraElements?
    let allowDelete: Bool?

    init(operationType: PaymentSession.Operation, extraElements: ExtraElements?, allowDelete: Bool?) {
        self.listOperationType = operationType
        self.extraElements = extraElements
        self.allowDelete = allowDelete
    }
}
