// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk

// - TODO: `RiskProviderResponder` could be moved to `Risk` module when network models will be extracted to a separate module

/// A collector that collects data from the risk provider and sends it back in a format required by API.
///
/// Data collector is used as mediation service between risk provider and risk service to transform reply from provider to response required by API.
struct RiskProviderDataCollector {
    let code: String
    let type: String?
    let riskProvider: RiskProvider?

    /// Initialize a responder for risks requests.
    /// - Parameters:
    ///   - code: risk provider's code
    ///   - type: risk provider's type
    ///   - riskProvider: risk provider (if exists), if no risk provider a default response will be returned (see `getProviderParameters`)
    init(code: String, type: String?, riskProvider: RiskProvider? = nil) {
        self.code = code
        self.type = type
        self.riskProvider = riskProvider
    }

    init(riskProvider: RiskProvider) {
        self.init(code: Swift.type(of: riskProvider).code, type: Swift.type(of: riskProvider).type, riskProvider: riskProvider)
    }

    /// Collect risk data and return it in `ProviderParameters` format.
    /// If risk provider wasn't initialized and an error occured during data collection return will have empty `parameters` array.
        guard let riskProvider = riskProvider else {
            return ProviderParameters(providerCode: code, providerType: type, parameters: [Parameter]())
        }
    func getProviderParameters() -> ProviderParameters {

        let collectedData: [String: String?]?

        do {
            collectedData = try riskProvider.collectRiskData()
        } catch {
            collectedData = nil

            if #available(iOS 14.0, *) {
                log(riskError: .riskDataCollectionFailed(underlyingError: error))
            }
        }

        let parameters = collectedData?.map {
            Parameter(name: $0.key, value: $0.value)
        } ?? [Parameter]()

        let providerParameters = ProviderParameters(providerCode: code, providerType: type, parameters: parameters)
        return providerParameters
    }
}

extension RiskProviderDataCollector: Loggable {
    @available(iOS 14, *)
    private func log(riskError: RiskProviderDataCollectorError) {
        switch riskError {
        case .riskDataCollectionFailed(let error):
            logger.critical("Unable to collect risk data from risk provider \(code, privacy: .private(mask: .hash)): \(error.localizedDescription, privacy: .private)")
        }
    }
}

enum RiskProviderDataCollectorError: Error {
    case riskDataCollectionFailed(underlyingError: Error)
}
