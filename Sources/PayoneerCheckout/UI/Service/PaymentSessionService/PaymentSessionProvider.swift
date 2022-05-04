// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

class PaymentSessionProvider {
    private let sharedTranslationProvider: SharedTranslationProvider
    private let provider: ListResultProvider
    private let connection: Connection
    private let paymentSessionURL: URL
    private var riskService: RiskService

    private var listResult: ListResult?

    init(paymentSessionURL: URL, connection: Connection, paymentServicesFactory: PaymentServicesFactory, localizationsProvider: SharedTranslationProvider, riskService: RiskService) {
        self.paymentSessionURL = paymentSessionURL
        self.connection = connection
        self.sharedTranslationProvider = localizationsProvider
        self.provider = ListResultProvider(connection: connection, paymentServicesFactory: paymentServicesFactory)
        self.riskService = riskService
    }

    func loadPaymentSession(completion: @escaping ((Result<UIModel.PaymentSession, Error>) -> Void)) {
        provider.fetchListResult(from: paymentSessionURL) { [weak self] result in
            guard let weakSelf = self else { return }

            weakSelf.listResult = weakSelf.provider.listResult

            switch result {
            case .success(let listResultNetworks):
                weakSelf.localize(listResultNetworks: listResultNetworks, completion: completion)
            case .failure(let error):
                // Even on a failure we need to try to download shared localization to localize errors
                if let listResult = weakSelf.provider.listResult {
                    weakSelf.fetchSharedLocalization(from: listResult) { _ in
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func localize(listResultNetworks: ListResultNetworks, completion: @escaping ((Result<UIModel.PaymentSession, Error>) -> Void)) {
        fetchSharedLocalization(from: listResultNetworks.listResult) { [weak self] result in
            guard let weakSelf = self else { return }

            switch result {
            case .success:
                let job = weakSelf.fetchNetworksLocalizations ->> weakSelf.createPaymentSession
                job(listResultNetworks, completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }

    }

    // MARK: - Asynchronous methods

    private func fetchSharedLocalization(from listResult: ListResult, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        guard let localeURL = listResult.links["lang"] else {
                let error = InternalError(description: "ListResult doesn't contain localization url")
                completion(.failure(error))
                return
        }

        sharedTranslationProvider.download(from: localeURL, using: connection) { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Just bypass in to out
            completion(.success(listResult))
        }
    }

    private func fetchNetworksLocalizations(filteredNetworks: ListResultNetworks, completion: @escaping (Result<DownloadTranslationService.Translations, Error>) -> Void) {
        let translationService = DownloadTranslationService(
            networks: filteredNetworks.filteredNetworks.applicableNetworks,
            accounts: filteredNetworks.filteredNetworks.accountRegistrations,
            presetAccount: filteredNetworks.filteredNetworks.presetAccount,
            sharedTranslation: sharedTranslationProvider)

        translationService.localize(using: connection, completion: completion)
    }

    // MARK: - Synchronous methods

    private func createPaymentSession(from translations: DownloadTranslationService.Translations, completion: ((Result<UIModel.PaymentSession, Error>) -> Void)) {
        guard let operationType = listResult?.operationType else {
            let error = InternalError(description: "Operation type or ListResult is not defined")
            completion(.failure(error))
            return
        }

        // PaymentSession.Operation contains only supported operation types by the framework
        guard let operation = UIModel.PaymentSession.Operation(rawValue: operationType) else {
            let error = InternalError(description: "Operation type is not known or supported: %@", operationType)
            completion(.failure(error))
            return
        }

        if let riskProviderParameters = listResult?.riskProviders {
            riskService.loadRiskProviders(withParameters: riskProviderParameters)
        }

        // Create a global payment context
        let context = UIModel.PaymentContext(operationType: operation, extraElements: listResult?.extraElements, riskService: riskService)

        let paymentSession = UIModel.PaymentSession(networks: translations.networks, accounts: translations.accounts, presetAccount: translations.presetAccount, context: context, allowDelete: listResult?.allowDelete)
        completion(.success(paymentSession))
    }
}
