// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation
import Risk
import Networking
import Logging

/// Service that fetches and stores PaymentSession.
/// Used by `PaymentListViewController`
class PaymentSessionService {
    let downloadProvider: DataDownloadProvider
    private let paymentSessionProvider: PaymentSessionProvider
    private let localizationProvider: TranslationProvider
    private let connection: Connection

    let paymentServicesFactory: PaymentServicesFactory

    weak var delegate: PaymentSessionServiceDelegate?

    init(paymentSessionURL: URL, connection: Connection, localizationProvider: SharedTranslationProvider, riskProviders: [RiskProvider.Type]) {
        self.connection = connection
        paymentServicesFactory = .init(connection: connection)
        downloadProvider = .init(connection: connection)
        paymentSessionProvider = .init(paymentSessionURL: paymentSessionURL, connection: connection, paymentServicesFactory: paymentServicesFactory, localizationsProvider: localizationProvider, riskProviders: riskProviders)
        self.localizationProvider = localizationProvider

        paymentServicesFactory.registerServices()
    }

    /// - Parameter completion: `LocalizedError` or `NSError` with localized description is always returned if `Load` produced an error.
    func loadPaymentSession() {
        paymentSessionProvider.loadPaymentSession { [self, weak delegate, firstSelectedNetwork] result in
            switch result {
            case .success(let session):
                DispatchQueue.main.async {
                    delegate?.paymentSessionService(didReceiveResult: .success(session))

                    if let selectedNetwork = firstSelectedNetwork(session) {
                        delegate?.paymentSessionService(shouldSelect: selectedNetwork, context: session.context)
                    }
                }
            case .failure(let error):
                if #available(iOS 14.0, *) {
                    error.log(to: logger)
                }

                // If server responded with ErrorInfo
                if let errorInfo = error as? ErrorInfo {
                    DispatchQueue.main.async {
                        delegate?.paymentSessionService(didReceiveResult: .failure(errorInfo))
                    }
                // If it is recoverable error (network error in our case)
                } else if type(of: self.connection.self).isRecoverableError(error) {
                    let interaction = Interaction(code: .ABORT, reason: .COMMUNICATION_FAILURE)
                    let errorInfo = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: interaction, underlyingError: error)
                    DispatchQueue.main.async {
                        delegate?.paymentSessionService(didReceiveResult: .failure(errorInfo))
                    }
                // In all other cases
                } else {
                    let interaction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
                    let errorInfo = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: interaction, underlyingError: error)
                    DispatchQueue.main.async {
                        delegate?.paymentSessionService(didReceiveResult: .failure(errorInfo))
                    }
                }
            }
        }
    }

    /// Return first preselected network in a session
    private func firstSelectedNetwork(in session: UIModel.PaymentSession) -> UIModel.PaymentNetwork? {
        for network in session.networks where network.applicableNetwork.selected == true {
            return network
        }

        return nil
    }
}

extension PaymentSessionService: Loggable {}
