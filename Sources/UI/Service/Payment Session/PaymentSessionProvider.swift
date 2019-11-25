import Foundation

class PaymentSessionProvider {
    private let paymentSessionURL: URL
    private let localizationQueue = OperationQueue()
    private let localizationsProvider: SharedTranslationProvider

    let connection: Connection
    
    init(paymentSessionURL: URL, connection: Connection, localizationsProvider: SharedTranslationProvider) {
        self.paymentSessionURL = paymentSessionURL
        self.connection = connection
        self.localizationsProvider = localizationsProvider
    }

    func loadPaymentSession(completion: @escaping ((Load<PaymentSession, Error>) -> Void)) {
        completion(.loading)

        let job = getListResult ->> downloadSharedLocalization ->> checkInteractionCode ->> filterUnsupportedNetworks ->> localize

        job(paymentSessionURL) { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let paymentNetworks):
                let paymentSession = weakSelf.createPaymentSession(from: paymentNetworks)
                completion(.success(paymentSession))
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
            case .success(let listResult): completion(.success(listResult))
            case .failure(let error): completion(.failure(error))
            }
        }
        getListResultOperation.start()
    }

    private func downloadSharedLocalization(for listResult: ListResult, completion: @escaping ((Result<ListResult, Error>) -> Void)) {
        guard let localeURL = listResult.networks.applicable.first?.links?[
            "lang"] else {
                let error = InternalError(description: "Applicable network language URL wasn't provided to a localization provider")
                completion(.failure(error))
                return
        }

        localizationsProvider.download(from: localeURL, using: connection) { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Just bypass in to out
            completion(.success(listResult))
        }
    }

    private func checkInteractionCode(listResult: ListResult, completion: ((Result<ListResult, Error>) -> Void)) {
        if listResult.interaction.interactionCode == .some(.PROCEED) {
            completion(.success(listResult))
            return
        }
        
        let localizedReason: String? =
            localizationsProvider.translation(forKey: listResult.interaction.code + "." + listResult.interaction.reason)

        let error: Error
        if let localizedReason = localizedReason {
            // If we have a localization for that interaction throw it as an error
            error = PaymentError(localizedDescription: localizedReason)
        } else {
            // If we don't have such localization throw an internal error, later it would be converted to a generic error
            error = InternalError(description: "%@", listResult.interaction.reason)
        }

        completion(.failure(error))
    }

    private func filterUnsupportedNetworks(listResult: ListResult, completion: (([ApplicableNetwork]) -> Void)) {
        // swiftlint:disable:next line_length
        let supportedCodes = ["AMEX", "CASTORAMA", "DINERS", "DISCOVER", "MASTERCARD", "UNIONPAY", "VISA", "VISA_DANKORT", "VISAELECTRON", "CARTEBANCAIRE", "MAESTRO", "MAESTROUK", "POSTEPAY", "SEPADD", "JCB"]

        let filteredPaymentNetworks = listResult.networks.applicable
            .filter { supportedCodes.contains($0.code) }

        completion(filteredPaymentNetworks)
    }

    private func localize(applicableNetworks: [ApplicableNetwork], completion: @escaping ((Result<[PaymentNetwork], Error>) -> Void)) {
        var operations = [DownloadTranslationOperation]()
        
        // That operation is called after all localizations were downloaded
        let completionOperation = BlockOperation { [localizationsProvider] in
            var paymentNetworks = [PaymentNetwork]()
            
            // Fill translations with operations' results
            for operation in operations {
                switch operation.result {
                case .some(.success(let translation)):
                    let combinedProvider = CombinedTranslationProvider(priorityTranslation: translation, otherProvider: localizationsProvider)
                    let paymentNetwork = PaymentNetwork(from: operation.network, localizeUsing: combinedProvider)
                    paymentNetworks.append(paymentNetwork)
                case .some(.failure(let error)):
                    // If translation wasn't downloaded don't proceed anymore, throw an error and exit
                    completion(.failure(error))
                    return
                case .none:
                    // Should never happen, but if...
                    let unexpectedError = InternalError(description: "Download localization operation wasn't completed")
                    completion(.failure(unexpectedError))
                }
            }
            
            completion(.success(paymentNetworks))
        }

        // Download translations for each network
        for network in applicableNetworks {
            do {
                let downloadTranslation = try DownloadTranslationOperation(for: network, using: connection)
                operations.append(downloadTranslation)
                completionOperation.addDependency(downloadTranslation)
                localizationQueue.addOperation(downloadTranslation)
            } catch {
                localizationQueue.cancelAllOperations()
                completion(.failure(error))
                return
            }
        }

        localizationQueue.addOperation(completionOperation)
    }
    
    // MARK: - Synchronous methods
    
    private func createPaymentSession(from paymentNetworks: [PaymentNetwork]) -> PaymentSession {
        return PaymentSession(networks: paymentNetworks)
    }
}
