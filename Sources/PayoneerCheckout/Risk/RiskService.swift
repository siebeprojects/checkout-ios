// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk

enum RiskServiceError: Error {
    case providerNotFound
    case initializationFailed(underlyingError: Error)
    case dataCollectionFailed(underlyingError: Error)
}

/// Service responsible for collecting data from all registered risk providers and returning response in required format for API.
struct RiskService {
    let providers: [RiskProvider.Type]

    private(set) var loadedProviders: [RiskProvider] = []
    private(set) var providerErrors: [RiskProviderError] = []

    init(providers: [RiskProvider.Type]) {
        self.providers = providers
    }
}

// MARK: - Operations

extension RiskService {
    mutating func loadRiskProviders(withParameters providerParameters: [ProviderParameters]) {
        loadedProviders = []
        providerErrors = []

        for parameters in providerParameters {
            do {
                let provider = try loadProvider(for: parameters)
                loadedProviders.append(provider)

            } catch let providerError as RiskProviderError {
                if #available(iOS 14, *) {
                    log(riskError: .providerNotFound, forProviderCode: parameters.providerCode)
                }

                providerErrors.append(providerError)

            } catch {
                if #available(iOS 14, *) {
                    log(riskError: .initializationFailed(underlyingError: error), forProviderCode: parameters.providerCode)
                }
            }
        }
    }

    mutating func collectRiskData() -> [ProviderParameters] {
        var providerParametersToSend: [ProviderParameters] = []

        /// Loop through loaded providers and transform the collected data into `ProviderParameters`. In case a provider error is thrown, it's stored in the `providerErrors` instance variable.
        for provider in loadedProviders {
            let code = Swift.type(of: provider).code
            let type = Swift.type(of: provider).type

            do {
                let collectedData = try provider.collectRiskData()

                let providerParameters = ProviderParameters(
                    providerCode: code,
                    providerType: type,
                    parameters: collectedData?.map { Parameter(name: $0.key, value: $0.value) } ?? []
                )

                providerParametersToSend.append(providerParameters)

            } catch {
                if #available(iOS 14.0, *) {
                    log(riskError: .dataCollectionFailed(underlyingError: error), forProviderCode: code)
                }

                if let providerError = error as? RiskProviderError {
                    providerErrors.append(providerError)
                }
            }
        }

        /// Loop through stored provider errors and transform them into `ProviderParameters`.
        for error in providerErrors {
            let providerParameters = ProviderParameters(
                providerCode: error.providerCode,
                providerType: error.providerType,
                parameters: [Parameter(name: error.name, value: error.reason)]
            )

            providerParametersToSend.append(providerParameters)
        }

        return providerParametersToSend
    }
}

// MARK: - Helpers

extension RiskService {
    private func loadProvider(for providerParameters: ProviderParameters) throws -> RiskProvider {
        guard let matchingProvider = providers.first(where: { $0.code == providerParameters.providerCode && $0.type == providerParameters.providerType }) else {
            throw RiskProviderError.internalFailure(
                reason: "Failed to load risk provider (code: \(providerParameters.providerCode)) (type: \(providerParameters.providerType ?? "-"))",
                providerCode: providerParameters.providerCode,
                providerType: providerParameters.providerType
            )
        }

        let parametersDictionary: [String: String?] = {
            let params = providerParameters.parameters ?? []
            return Dictionary(uniqueKeysWithValues: params.map { ($0.name, $0.value) })
        }()

        return try matchingProvider.load(withParameters: parametersDictionary)
    }
}

// MARK: - Loggable

extension RiskService: Loggable {
    @available(iOS 14, macOS 11.0, *)
    private func log(riskError: RiskServiceError, forProviderCode providerCode: String) {
        switch riskError {
        case .providerNotFound:
            logger.critical("Unable to find a requested risk provider \(providerCode, privacy: .private(mask: .hash)): \(riskError.localizedDescription, privacy: .private)")
        case .initializationFailed(let error):
            logger.critical("Failed to initialize the risk provider \(providerCode, privacy: .private(mask: .hash)): \(error.localizedDescription, privacy: .private)")
        case .dataCollectionFailed(let error):
            logger.critical("Unable to collect risk data from risk provider \(providerCode, privacy: .private(mask: .hash)): \(error.localizedDescription, privacy: .private)")
        }
    }
}
