// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension Input {
    /// A namespace with utilities to help automatically switch networks depending on account number.
    enum SmartSwitch {}
}

// MARK: - Rule

extension Input.SmartSwitch {
    /// Rule to detect network type based on regular expreession
    struct Rule: Decodable {
        /// Network code
        let code: String

        /// Regular expression
        let regex: String
    }

    fileprivate struct Root: Decodable {
        let items: [Rule]
    }
}

extension Sequence where Element == Input.SmartSwitch.Rule {
    /// First found rule with specified network code
    func first(withCode: String) -> Element? {
        for element in self where element.code == withCode {
            return element
        }

        return nil
    }
}

// MARK: - Provider

extension Input.SmartSwitch {
    /// Provides SmartSwitch rules
    class Provider {
        func getRules() throws -> [Rule] {
            let groupingData = try AssetProvider.getGroupingRulesData()
            let root = try JSONDecoder().decode(Root.self, from: groupingData)
            return root.items
        }
    }
}

// MARK: - Selector

extension Input.SmartSwitch {
    class Selector {
        let networks: [Input.Network]

        /// First network in `networks` array, used to avoid optional unwrapping
        let firstNetwork: Input.Network

        private(set) var selected: DetectedNetwork

        init(networks: [Input.Network]) throws {
            self.networks = networks

            guard let firstNetwork = networks.first else {
                throw InternalError(description: "Tried to initialize with empty networks array")
            }

            self.firstNetwork = firstNetwork

            if networks.count == 1 {
                // If only 1 network is present - it is always specific
                selected = .specific(firstNetwork)
            } else {
                // We don't know the account number for now, we will show the first network from an array
                selected = .generic(firstNetwork)
            }
        }
    }
}

extension Input.SmartSwitch.Selector {
    /// Find an appropriate network for the specified account number.
    func select(usingAccountNumber accountNumber: String) -> DetectedNetwork {
        if networks.count == 1 {
            // Keep specific network if only 1 network is in array
            return selected
        }

        let previouslySelected = selected
        var newSelection: DetectedNetwork?

        // Try to find a specific network
        for network in networks {
            guard let rule = network.switchRule else { continue }

            let isMatched = (accountNumber.range(of: rule.regex, options: .regularExpression) != nil)
            guard isMatched else { continue }

            newSelection = .specific(network)
        }

        if let newSelection = newSelection {
            selected = newSelection
        } else {
            // Unable to find, return the first network
            // Specified in [PCX-2227](https://optile.atlassian.net/browse/PCX-2227)
            selected = .generic(firstNetwork)
        }

        if previouslySelected.network != selected.network {
            let oldInputFields: [WritableInputField] = previouslySelected.network.uiModel.inputSections
                .flatMap { $0.inputFields }
                .compactMap { $0 as? WritableInputField }
            let newInputFields: [WritableInputField] = selected.network.uiModel.inputSections
                .flatMap { $0.inputFields }
                .compactMap { $0 as? WritableInputField }

            moveInputValues(from: oldInputFields, to: newInputFields)
        }

        return selected
    }

    /// Move input values from `WritableInputField` to `WritableInputField`.
    private func moveInputValues(from lhs: [WritableInputField], to rhs: [WritableInputField]) {
        for fromInputField in lhs {
            for toInputField in rhs where toInputField.id == fromInputField.id {
                if let toResettableInputField = toInputField as? ContainsDefaultValue {
                    // Don't move values if value should be resetted
                    toInputField.value = toResettableInputField.defaultValue
                } else {
                    toInputField.value = fromInputField.value
                }
            }

            fromInputField.value = String()
        }
    }

    enum DetectedNetwork: Equatable {
        /// Specific network wasn't detected, using a generic one
        case generic(Input.Network)

        /// Account number is valid for one of specific networks.
        /// - Note: that case is also used if only 1 network is present.
        case specific(Input.Network)

        var network: Input.Network {
            switch self {
            case .generic(let genericNetwork): return genericNetwork
            case .specific(let specificNetwork): return specificNetwork
            }
        }
    }
}
