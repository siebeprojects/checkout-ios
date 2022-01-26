// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

struct PresetResponseBuilder {
    func createResponse(for presetAccount: PresetAccount) -> Result<OperationResult, ErrorInfo> {
        let interaction: Interaction

        switch createInteraction(from: presetAccount.redirect) {
        case .success(let createdInteraction): interaction = createdInteraction
        case .failure(let errorInfo): return .failure(errorInfo)
        }

        let operationResult = OperationResult(
            resultInfo: "PresetAccount selected",
            links: nil,
            interaction: interaction,
            redirect: presetAccount.redirect,
            providerResponse: nil)

        return .success(operationResult)
    }

    /// Create `Interaction` object from parameters inside redirect.
    /// - Returns: `Interaction` or `ErrorInfo` if needed parameters are not found
    private func createInteraction(from redirect: Redirect) -> Result<Interaction, ErrorInfo> {
        guard
            let interactionCode = redirect.parameters?["interactionCode"],
            let interactionReason = redirect.parameters?["interactionReason"]
        else {
            let error = CustomErrorInfo(
                resultInfo: "Missing Interaction code and reason inside PresetAccount.redirect",
                interaction: Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR),
                underlyingError: nil)
            return .failure(error)
        }

        let interaction = Interaction(code: interactionCode, reason: interactionReason)
        return .success(interaction)
    }
}

private extension Sequence where Element == Parameter {
    /// Returns a value for parameter with specified name
    subscript(name: String) -> String? {
        return first(where: { $0.name == name })?.value
    }
}
