import Foundation

/// Service that fetches and stores PaymentSession.
/// Used by `PaymentListViewController`
class PaymentSessionService {
    private let paymentSessionProvider: PaymentSessionProvider
    private let downloadProvider: DataDownloadProvider
    private let localizationProvider: TranslationProvider

    init(paymentSessionURL: URL, connection: Connection, localizationProvider: SharedTranslationProvider) {
        downloadProvider = DataDownloadProvider(connection: connection)
        paymentSessionProvider = PaymentSessionProvider(paymentSessionURL: paymentSessionURL, connection: connection, localizationsProvider: localizationProvider)
        self.localizationProvider = localizationProvider
    }

    /// - Parameter completion: `LocalizedError` or `NSError` with localized description is always returned if `Load` produced an error.
    func loadPaymentSession(loadDidComplete: @escaping (Load<PaymentSession, Error>) -> Void, shouldSelect: @escaping (PaymentNetwork) -> Void) {
        paymentSessionProvider.loadPaymentSession { [firstSelectedNetwork, localize] result in
            switch result {
            case .loading: loadDidComplete(.loading)
            case .success(let session):
                loadDidComplete(.success(session))
                if let selectedNetwork = firstSelectedNetwork(session) {
                    shouldSelect(selectedNetwork)
                }
            case .failure(let error):
                log(error)

                let localizedError = localize(error)
                loadDidComplete(.failure(localizedError))
            }
        }
    }

    func loadLogo(_ logo: PaymentNetwork.Logo, completion: @escaping ((Data?) -> Void)) {
        downloadProvider.downloadData(from: logo.url) { result in
            switch result {
            case .success(let logoData):
                completion(logoData)
            case .failure(let error):
                let paymentError = InternalError(
                    description: "Couldn't download a logo for a payment network %@ from %@, reason: %@",
                    logo.url.absoluteString, error.localizedDescription)
                paymentError.log()
                completion(nil)
            }
        }
    }

    private func localize(error: Error) -> Error {
        switch error {
        case let localizedError as LocalizedError:
            return localizedError
        case let error where error.asNetworkError != nil:
            // Network errors has built-in localizations
            return error
        default:
            let description: String = localizationProvider.translation(forKey: LocalTranslation.errorDefault.rawValue)
            return PaymentError(localizedDescription: description, underlyingError: error)
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
