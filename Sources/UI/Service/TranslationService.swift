import Foundation

/// Service responsible for localization file downloads and model localizations
final class TranslationService {
    private let networks: [ApplicableNetwork]
    private let accounts: [AccountRegistration]
    private let sharedTranslationProvider: TranslationProvider
    
    private let localizationQueue = OperationQueue()
    
    private var downloadNetworkOperations = [DownloadTranslationOperation<ApplicableNetwork>]()
    private var downloadAccountsOperations = [DownloadTranslationOperation<AccountRegistration>]()
    
    typealias ConvertedNetworksTuple = (paymentNetworks: [PaymentNetwork], registeredAccounts: [RegisteredAccount])
    typealias CompletionBlock = (Result<ConvertedNetworksTuple, Error>) -> Void
    
    init(networks: [ApplicableNetwork], accounts: [AccountRegistration], sharedTranslation: SharedTranslationProvider) {
        self.networks = networks
        self.accounts = accounts
        self.sharedTranslationProvider = sharedTranslation
    }
    
    func localize(using connection: Connection, completion: @escaping CompletionBlock) {
        // We should never call that method twice but we need to protect from that situation
        localizationQueue.cancelAllOperations()
        downloadNetworkOperations = .init()
        downloadAccountsOperations = .init()

        // That operation is called after all localizations were downloaded
        let completionOperation = BlockOperation { [translate] in
            translate(completion)
        }
                
        do {
            // Download translations for each network
            for network in networks {
                let downloadTranslation = try DownloadTranslationOperation(for: network, using: connection)
                downloadNetworkOperations.append(downloadTranslation)
                
                completionOperation.addDependency(downloadTranslation)
                localizationQueue.addOperation(downloadTranslation)
            }
            
            // Download translation for each registered account
            for account in accounts {
                let downloadTranslation = try DownloadTranslationOperation(for: account, using: connection)
                downloadAccountsOperations.append(downloadTranslation)
                
                completionOperation.addDependency(downloadTranslation)
                localizationQueue.addOperation(downloadTranslation)
            }
        } catch {
            localizationQueue.cancelAllOperations()
            completion(.failure(error))
            return
        }
        
        localizationQueue.addOperation(completionOperation)
    }
    
    /// Perform a translation using downloaded localization files.
    private func translate(completion: CompletionBlock) {
        // Fill translations with downloaded results for **networks**
        var paymentNetworks = [PaymentNetwork]()

        for operation in downloadNetworkOperations {
            switch operation.result {
            case .some(.success(let translation)):
                let combinedProvider = CombinedTranslationProvider(priorityTranslation: translation, otherProvider: sharedTranslationProvider)
                let paymentNetwork = PaymentNetwork(from: operation.model, localizeUsing: combinedProvider)
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
        
        // Fill translations with downloaded results for **registered accounts**
        var registeredAccounts = [RegisteredAccount]()
        
        for operation in downloadAccountsOperations {
            switch operation.result {
            case .some(.success(let translation)):
                let combinedProvider = CombinedTranslationProvider(priorityTranslation: translation, otherProvider: sharedTranslationProvider)
                let account = RegisteredAccount(from: operation.model, localizeUsing: combinedProvider)
                registeredAccounts.append(account)
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
        
        let resultTuple = (paymentNetworks, registeredAccounts)
        completion(.success(resultTuple))
    }
}

// MARK: - DownloadTranslationOperation

private class DownloadTranslationOperation<T>: SendRequestOperation<DownloadLocalization> where T: Network {
    let model: T
     
    init(for model: T, using connection: Connection) throws {
        guard let localizationURL = model.localizationURL else {
            throw InternalError(description: "Model doesn't contain a localization URL. Model: %@", objects: model)
        }
        
        self.model = model
        
        let downloadRequest = DownloadLocalization(from: localizationURL)
        super.init(connection: connection, request: downloadRequest)
    }
 }

private protocol Network {
    var code: String { get }
    var localizationURL: URL? { get }
}

extension ApplicableNetwork: Network {
    var localizationURL: URL? { self.links?["lang"] }
}

extension AccountRegistration: Network {
    var localizationURL: URL? { self.links["lang"] }
}
