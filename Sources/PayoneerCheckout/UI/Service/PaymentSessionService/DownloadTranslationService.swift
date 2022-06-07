// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Networking

/// Service responsible for localization file downloads and model localizations
final class DownloadTranslationService {
    private let networks: [ApplicableNetwork]
    private let accounts: [AccountRegistration]
    private let presetAccount: PresetAccount?
    private let sharedTranslationProvider: TranslationProvider

    private let localizationQueue = OperationQueue()

    private var downloadNetworkOperations = [DownloadTranslationOperation<ApplicableNetwork>]()
    private var downloadAccountsOperations = [DownloadTranslationOperation<AccountRegistration>]()
    private var downloadPresetAccountOperation: DownloadTranslationOperation<PresetAccount>?

    // MARK: Output

    class Translations {
        fileprivate(set) var networks: [TranslatedModel<ApplicableNetwork>] = .init()
        fileprivate(set) var accounts: [TranslatedModel<AccountRegistration>] = .init()
        fileprivate(set) var presetAccount: TranslatedModel<PresetAccount>?
    }

    init(networks: [ApplicableNetwork], accounts: [AccountRegistration], presetAccount: PresetAccount?, sharedTranslation: SharedTranslationProvider) {
        self.networks = networks
        self.accounts = accounts
        self.presetAccount = presetAccount
        self.sharedTranslationProvider = sharedTranslation
    }

    func localize(using connection: Connection, completion: @escaping (Result<Translations, Error>) -> Void) {
        // We should never call that method twice but we need to protect from that situation
        localizationQueue.cancelAllOperations()
        downloadNetworkOperations = .init()
        downloadAccountsOperations = .init()

        // That operation is called after all localizations were downloaded
        let completionOperation = BlockOperation { [createTranslatedModels] in
            do {
                let translations = try createTranslatedModels()
                completion(.success(translations))
            } catch {
                completion(.failure(error))
            }
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

            if let presetAccount = presetAccount {
                let downloadTranslation = try DownloadTranslationOperation(for: presetAccount, using: connection)
                downloadPresetAccountOperation = downloadTranslation
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

    /// Create `Translations` object with models and translators to return it as class' outupt
    private func createTranslatedModels() throws -> Translations {
        let translations = Translations()

        for operation in downloadNetworkOperations {
            let translatedNetwork = try createTranslatedModel(fromDownloadTranslationResult: operation.result, for: operation.model)
            translations.networks.append(translatedNetwork)
        }

        for operation in downloadAccountsOperations {
            let translatedAccount = try createTranslatedModel(fromDownloadTranslationResult: operation.result, for: operation.model)
            translations.accounts.append(translatedAccount)
        }

        if let downloadPresetAccountOperation = downloadPresetAccountOperation {
            let translatedPresetAccount = try createTranslatedModel(fromDownloadTranslationResult: downloadPresetAccountOperation.result, for: downloadPresetAccountOperation.model)
            translations.presetAccount = translatedPresetAccount
        }

        return translations
    }

    /// Create `TranslatedModel` from download translation result provided by `DownloadTranslationOperation`
    private func createTranslatedModel<T>(fromDownloadTranslationResult result: Result<[String: String], Error>?, for model: T) throws -> TranslatedModel<T> {
        switch result {
        case .some(.success(let translation)):
            let combinedProvider = CombinedTranslationProvider(priorityTranslation: translation, otherProvider: sharedTranslationProvider)
            let translatedNetwork = TranslatedModel(model: model, translator: combinedProvider)
            return translatedNetwork
        case .some(.failure(let error)):
            // If translation wasn't downloaded don't proceed anymore, throw an error and exit
            throw error
        case .none:
            // Should never happen, but if...
            throw InternalError(description: "Download localization operation wasn't completed")
        }
    }
}

// MARK: - DownloadTranslationOperation

private class DownloadTranslationOperation<T>: SendRequestOperation<NetworkRequest.DownloadLocalization> where T: Network {
    let model: T

    init(for model: T, using connection: Connection) throws {
        guard let localizationURL = model.localizationURL else {
            throw InternalError(description: "Model doesn't contain a localization URL. Model: %@", objects: model)
        }

        self.model = model

        let downloadRequest = NetworkRequest.DownloadLocalization(from: localizationURL)
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

extension PresetAccount: Network {
    var localizationURL: URL? { self.links["lang"] }
}
