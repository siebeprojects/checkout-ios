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

        let job = getListResult ->> downloadSharedLocalization ->> checkInteractionCode ->> filterUnsupportedNetworks ->> downloadLocalizations

        job(paymentSessionURL) { [weak self] result in
            guard let weakSelf = self else { return }
            
            switch result {
            case .success(let translationsByApplicableNetwork):
                let paymentNetworks = weakSelf.transform(translationsByApplicableNetwork: translationsByApplicableNetwork)
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

    private func downloadLocalizations(for applicableNetworks: [ApplicableNetwork], completion: @escaping ((Result<[ApplicableNetwork: Dictionary<String, String>], Error>) -> Void)) {
        var translationsByApplicableNetwork: [ApplicableNetwork: Dictionary<String, String>] = [:]
        
        let completionOperation = BlockOperation {
            completion(.success(translationsByApplicableNetwork))
        }

        for network in applicableNetworks {
            guard let localizationURL = network.links?["lang"] else {
                let error = InternalError(description: "Applicable network doesn't contain localization URL. Network: %@", objects: network)
                completion(.failure(error))
                return
            }
            
            let request = DownloadLocalization(from: localizationURL)
            let downloadOperation = SendRequestOperation(connection: connection, request: request)
            downloadOperation.downloadCompletionBlock = { [localizationQueue] result in
                switch result {
                case .success(let translation): translationsByApplicableNetwork[network] = translation
                case .failure(let error):
                    localizationQueue.cancelAllOperations()
                    completion(.failure(error))
                }
            }
            
            completionOperation.addDependency(downloadOperation)
            localizationQueue.addOperation(downloadOperation)
        }

        localizationQueue.addOperation(completionOperation)
    }
    
    // MARK: - Synchronous methods
    
    private func transform(translationsByApplicableNetwork: [ApplicableNetwork: Dictionary<String, String>]) -> [PaymentNetwork] {
        var paymentNetworks: [PaymentNetwork] = []
        for (applicableNetwork, translation) in translationsByApplicableNetwork {
            let combinedProvider = CombinedTranslationProvider(priorityTranslation: translation, otherProvider: localizationsProvider)
            let paymentNetwork = PaymentNetwork(from: applicableNetwork, localizeUsing: combinedProvider)
            paymentNetworks.append(paymentNetwork)
        }
        
        return paymentNetworks
    }

    private func createPaymentSession(from paymentNetworks: [PaymentNetwork]) -> PaymentSession {
        return PaymentSession(networks: paymentNetworks)
    }
}
