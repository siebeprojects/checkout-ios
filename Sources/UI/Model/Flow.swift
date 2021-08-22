// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Flow is almost the same as the `operationType` in the root of the LIST object but it could has `DELETE` state if the OPG response was triggered by deleting a payment method, regardless of the `operationType`.
///
/// In other words, flow can be either `CHARGE`, `UPDATE`, `PAYOUT` (or any other `operationType`) or `DELETE` (so-called “virtual” flow, since it does not map to an `operationType`, because deleting a payment method can be carried out regardless of `operationType`.
enum Flow {
    case charge, update, delete

    @available(*, unavailable, message: "Not yet implemented")
    case payout
}
