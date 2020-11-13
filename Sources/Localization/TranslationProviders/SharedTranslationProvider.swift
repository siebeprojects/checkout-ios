// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Provider is used to keep globally shared translations: built-in local translation and remote shared translation.
class SharedTranslationProvider: TranslationProvider {
    private let localTranslations: [String: String]
    private var remoteSharedTranslations: [String: String] = [:]

    var translations: [[String: String]] {
        return [remoteSharedTranslations, localTranslations]
    }

    init(localTranslations: [String: String] = TranslationKey.allCasesAsDictionary) {
        self.localTranslations = localTranslations
    }

    func download(from url: URL, using connection: Connection, completion: @escaping ((Error?) -> Void)) {
        let paymentPageURL: URL

        do {
            paymentPageURL = try url.transformToPaymentPageLocalizationURL()
        } catch {
            completion(error)
            return
        }

        let downloadLocalizationRequest = DownloadLocalization(from: paymentPageURL)
        let sendRequestOperation = SendRequestOperation(connection: connection, request: downloadLocalizationRequest)
        sendRequestOperation.downloadCompletionBlock = { result in
            switch result {
            case .success(let translation):
                self.remoteSharedTranslations = translation
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }

        sendRequestOperation.start()
    }
}

private extension URL {
    /// Transform any applicable network url to paymentpage localization url.
    ///
    /// Example:
    /// - From: `https://resources.sandbox.oscato.com/resource/lang/VASILY_DEMO/en_US/VISAELECTRON.properties`
    /// - To: `https://resources.sandbox.oscato.com/resource/lang/VASILY_DEMO/en_US/checkout.properties`
    func transformToPaymentPageLocalizationURL() throws -> URL {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            let error = InternalError(description: "Incorrect shared translation URL: %@", self.absoluteString)
            throw error
        }

        guard let lastPathComponent = components.path.components(separatedBy: "/").last else {
            let error = InternalError(description: "Unable to find the last path component in url %@", self.absoluteString)
            throw error
        }

        var updatedComponents = components
        updatedComponents.path = components.path.replacingOccurrences(of: lastPathComponent, with: "checkout.properties")

        guard let paymentPageURL = updatedComponents.url else {
            let error = InternalError(description: "Unable for form a url from URLComponents: %@", "\(updatedComponents)")
            throw error
        }

        return paymentPageURL
    }
}

private extension TranslationKey {
    static var allCasesAsDictionary: [String: String] {
        var dictionary = [String: String]()

        for translation in TranslationKey.allCases {
            dictionary[translation.rawValue] = translation.localizedString
        }

        return dictionary
    }
}
