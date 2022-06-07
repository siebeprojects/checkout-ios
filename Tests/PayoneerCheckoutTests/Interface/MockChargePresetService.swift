// Copyright (c) 2022 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
@testable import PayoneerCheckout
import Networking

final class MockChargePresetService: ChargePresetServiceProtocol {
    enum Result {
        case completion
        case authenticationChallenge
    }

    var result: MockChargePresetService.Result = .completion

    func chargePresetAccount(usingListResultURL listResultURL: URL, completion: @escaping (CheckoutResult) -> Void, presentationRequest: @escaping (UIViewController) -> Void) {
        switch result {
        case .completion:
            completion(CheckoutResult(operationResult: .failure(ErrorInfo(resultInfo: "", interaction: Interaction(code: "", reason: "")))))
        case .authenticationChallenge:
            presentationRequest(UIViewController())
        }
    }
}
