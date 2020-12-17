// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// Service that fetches and stores PaymentSession.
/// Used by `PaymentListViewController`
class PaymentSessionService {
    let downloadProvider: DataDownloadProvider
    private let paymentSessionProvider: PaymentSessionProvider
    private let localizationProvider: TranslationProvider

    let paymentServicesFactory: PaymentServicesFactory
    
    weak var delegate: PaymentSessionServiceDelegate?

    init(paymentSessionURL: URL, connection: Connection, localizationProvider: SharedTranslationProvider) {
        paymentServicesFactory = PaymentServicesFactory(connection: connection)
        downloadProvider = DataDownloadProvider(connection: connection)
        paymentSessionProvider = PaymentSessionProvider(paymentSessionURL: paymentSessionURL, connection: connection, paymentServicesFactory: paymentServicesFactory, localizationsProvider: localizationProvider)
        self.localizationProvider = localizationProvider

        paymentServicesFactory.registerServices()
    }

    /// - Parameter completion: `LocalizedError` or `NSError` with localized description is always returned if `Load` produced an error.
    func loadPaymentSession() {
        paymentSessionProvider.loadPaymentSession { [weak delegate, firstSelectedNetwork] result in
            switch result {
            case .loading:
                DispatchQueue.main.async {
                    delegate?.paymentSessionService(loadingDidCompleteWith: .loading)
                }
            case .success(let session):
                DispatchQueue.main.async {
                    delegate?.paymentSessionService(loadingDidCompleteWith: .success(session))

                    if let selectedNetwork = firstSelectedNetwork(session) {
                        delegate?.paymentSessionService(shouldSelect: selectedNetwork)
                    }
                }
            case .failure(let error):
                log(error)

                DispatchQueue.main.async {
                    delegate?.paymentSessionService(loadingDidCompleteWith: .failure(error))
                }
            }
        }
    }

    /// Return first preselected network in a session
    private func firstSelectedNetwork(in session: PaymentSession) -> PaymentNetwork? {
        for network in session.networks {
            if network.applicableNetwork.selected == true {
                return network
            }
        }

        return nil
    }
}

/// Enumeration that is used for any object that can't be instantly loaded (e.g. fetched from a network)
enum Load<Success, ErrorType> where ErrorType: Error {
    case loading
    case failure(ErrorType)
    case success(Success)
}
