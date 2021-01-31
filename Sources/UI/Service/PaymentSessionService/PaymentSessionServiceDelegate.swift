// Copyright (c) 2020–2021 Payoneer Germany GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

protocol PaymentSessionServiceDelegate: class {
    func paymentSessionService(loadingDidCompleteWith result: Load<PaymentSession, ErrorInfo>)
    func paymentSessionService(shouldSelect network: PaymentNetwork)
}
