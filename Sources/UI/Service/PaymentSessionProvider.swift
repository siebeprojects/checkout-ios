// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

class PaymentSessionProvider {
    private let paymentSessionURL: URL
    private let sharedTranslationProvider: SharedTranslationProvider
    private let paymentServicesFactory: PaymentServicesFactory

    let connection: Connection

    var listResult: ListResult?

    init(paymentSessionURL: URL, connection: Connection, paymentServicesFactory: PaymentServicesFactory, localizationsProvider: SharedTranslationProvider) {
        self.paymentSessionURL = paymentSessionURL
        self.connection = connection
        self.sharedTranslationProvider = localizationsProvider
        self.paymentServicesFactory = paymentServicesFactory
    }

    func loadPaymentSession(completion: @escaping ((Load<PaymentSession, Error>) -> Void)) {
        completion(.loading)

        let job = getListResult ->> checkIntegrationType ->> checkOperationType ->> downloadSharedLocalization ->> checkInteractionCode ->> filterUnsupportedNetworks ->> localize

        job(paymentSessionURL) { [weak self] result in
            guard let weakSelf = self else { return }

            switch result {
            case .success(let paymentNetworks):
                do {
                    let paymentSession = try weakSelf.createPaymentSession(from: paymentNetworks)
                    completion(.success(paymentSession))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Asynchronous methods

    private func getListResult(from url: URL, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        let getListResult = GetListResult(url: paymentSessionURL)
        let getListResultOperation = SendRequestOperation(connection: connection, request: getListResult)
        getListResultOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let listResult):
                self.listResult = listResult
                completion(.success(listResult))
            case .failure(let error): completion(.failure(error))
            }
        }
        getListResultOperation.start()
    }
    
    private func checkIntegrationType(for listResult: ListResult, completion: ((Result<ListResult, Error>) -> Void)) {
        guard listResult.integrationType == "MOBILE_NATIVE" else {
            let interaction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
            let resultInfo = "Integration type is not supported: " + listResult.integrationType
            let paymentError = CustomErrorInfo(resultInfo: resultInfo, interaction: interaction, underlyingError: nil)
            completion(.failure(paymentError))
            return
        }

        completion(.success(listResult))
    }

    private func checkOperationType(for listResult: ListResult, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        guard let operationType = listResult.operationType else {
            let error = InternalError(description: "Operation type is not specified")
            completion(.failure(error))
            return
        }

        guard let operation = Operation(rawValue: operationType) else {
            let error = InternalError(description: "Operation type is not known: %@", operationType)
            completion(.failure(error))
            return
        }

        guard case .CHARGE = operation else {
            let error = InternalError(description: "Operation type is not supported: %@", operationType)
            completion(.failure(error))
            return
        }

        completion(.success(listResult))
    }

    private func downloadSharedLocalization(for listResult: ListResult, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
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

    private func checkInteractionCode(listResult: ListResult, completion: ((Result<ListResult, Error>) -> Void)) {
        if Interaction.Code(rawValue: listResult.interaction.code) == .some(.PROCEED) {
            completion(.success(listResult))
            return
        }

        let localizedReason: String? =
            sharedTranslationProvider.translation(forKey: listResult.interaction.code + "." + listResult.interaction.reason)

        let error: Error
        if let localizedReason = localizedReason {
            // If we have a localization for that interaction throw it as an error
            error = TranslatedError(localizedDescription: localizedReason)
        } else {
            // If we don't have such localization throw an internal error, later it would be converted to a generic error
            error = InternalError(description: "%@", listResult.interaction.reason)
        }

        completion(.failure(error))
    }

    private typealias APINetworksTuple = (applicableNetworks: [ApplicableNetwork], accountRegistrations: [AccountRegistration])

    private func filterUnsupportedNetworks(listResult: ListResult, completion: ((APINetworksTuple) -> Void)) {
        let filteredPaymentNetworks = listResult.networks.applicable.filter { (network) -> Bool in
            paymentServicesFactory.isSupported(networkCode: network.code, paymentMethod: network.method)
        }

        let filteredRegisteredNetworks: [AccountRegistration]
        if let accounts = listResult.accounts {
            filteredRegisteredNetworks = accounts.filter {
                paymentServicesFactory.isSupported(networkCode: $0.code, paymentMethod: $0.method)
            }
        } else {
            filteredRegisteredNetworks = .init()
        }

        completion((filteredPaymentNetworks, filteredRegisteredNetworks))
    }

    private func localize(tuple: APINetworksTuple, completion: @escaping (Result<DownloadTranslationService.Translations, Error>) -> Void) {
        let translationService = DownloadTranslationService(networks: tuple.applicableNetworks, accounts: tuple.accountRegistrations, sharedTranslation: sharedTranslationProvider)
        translationService.localize(using: connection, completion: completion)
    }

    // MARK: - Synchronous methods

    private func createPaymentSession(from translations: DownloadTranslationService.Translations) throws -> PaymentSession {
        guard let operationType = listResult?.operationType else {
            throw InternalError(description: "Operation type or ListResult is not defined")
        }

        return .init(operationType: operationType, networks: translations.networks, accounts: translations.accounts)
    }
}

private extension PaymentSessionProvider {
    enum Operation: String {
        case CHARGE
    }
}
