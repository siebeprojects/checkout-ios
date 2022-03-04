// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

#if canImport(Risk)
import Risk
#endif

// TODO: `RiskService` could be moved to `Risk` module when network models will be extracted to a separate module

/// Service responsible for collecting data from all registered risk providers and returning response in required format for API.
struct RiskService {
    private let registry: RiskProviderRegistry
    private(set) var dataCollectors = [RiskProviderDataCollector]()

    init(registry: RiskProviderRegistry) {
        self.registry = registry
    }
}

// MARK: - Load risk providers

extension RiskService {
    mutating func loadRiskProviders(using providerParameters: [ProviderParameters]) {
        dataCollectors = .init()

        for parameters in providerParameters {
            guard let provider = loadRiskProvider(using: parameters) else {
                if #available(iOS 14.0, *) {
                    log(riskError: .providerNotFound, forProviderCode: parameters.providerCode)
                }

                let dataCollector = RiskProviderDataCollector(code: parameters.providerCode, type: parameters.providerType)
                dataCollectors.append(dataCollector)
                continue
            }

            let dataCollector = RiskProviderDataCollector(riskProvider: provider)
            dataCollectors.append(dataCollector)
        }
    }

    private func loadRiskProvider(using providerParameters: ProviderParameters) -> RiskProvider? {
        guard let providerType = lookUp(providerCode: providerParameters.providerCode, providerType: providerParameters.providerType) else {
            return nil
        }

        // Load a provider
        let parametersDictionary = Dictionary(uniqueKeysWithValues: providerParameters.parameters.map {
            ($0.name, $0.value)
        })

        do {
            return try providerType.load(using: parametersDictionary)
        } catch {
            if #available(iOS 14, *) {
                log(riskError: .initializationFailed(underlyingError: error), forProviderCode: providerParameters.providerCode)
            }

            return nil
        }
    }

    private func lookUp(providerCode: String, providerType: String?) -> RiskProvider.Type? {
        return registry.registeredProviders.first {
            $0.code == providerCode && $0.type == providerType
        }
    }
}

// MARK: - Risk data

extension RiskService {
    /// - Returns: risk data packed in provider parameters or `nil` if no risk data should be returned (in case if provider doesn't provide it).
    func collectRiskData() -> [ProviderParameters]? {
        let data: [ProviderParameters] = dataCollectors.map {
            $0.getProvidersParameters()
        }

        return data.isEmpty ? nil : data
    }
}

// MARK: - Loggable

private enum RiskServiceError: Error {
    case providerNotFound
    case initializationFailed(underlyingError: Error)
}

extension RiskService: Loggable {
    @available(iOS 14, macOS 11.0, *)
    private func log(riskError: RiskServiceError, forProviderCode providerCode: String) {
        switch riskError {
        case .providerNotFound:
            logger.critical("Unable to find a requested risk provider \(providerCode, privacy: .private(mask: .hash)): \(riskError.localizedDescription, privacy: .private)")
        case .initializationFailed(let initError):
            logger.critical("Failed to initialize the risk provider \(providerCode, privacy: .private(mask: .hash)): \(initError.localizedDescription, privacy: .private)")
        }
    }
}
