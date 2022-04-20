// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
@testable import PayoneerCheckout

final class MockChargePresetService: ChargePresetServiceProtocol {
    enum Result {
        case completion
        case authenticationChallenge
    }

    var result: MockChargePresetService.Result = .completion

    func chargePresetAccount(usingListResultURL listResultURL: URL, completion: @escaping (CheckoutResult) -> Void, authenticationChallengeReceived: @escaping (URL) -> Void) {
        switch result {
        case .completion:
            completion(CheckoutResult(operationResult: .failure(ErrorInfo(resultInfo: "", interaction: Interaction(code: "", reason: "")))))
        case .authenticationChallenge:
            authenticationChallengeReceived(URL(string: "https://")!)
        }
    }
}
