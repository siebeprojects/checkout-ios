// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import UIKit

@objc public final class PaymentListViewController: UIViewController {
    weak var methodsTableView: UITableView?
    weak var activityIndicator: UIActivityIndicatorView?
    weak var errorAlertController: UIAlertController?

    let sessionService: PaymentSessionService

    let sharedTranslationProvider: SharedTranslationProvider
    fileprivate let router: List.Router

    public weak var delegate: PaymentDelegate?

    let stateManager = StateManager()
    let viewManager = ViewManager()
    fileprivate let operationResultHandler = OperationResultHandler()

    lazy private(set) var slideInPresentationManager = SlideInPresentationManager()

    /// - Parameter listResultURL: URL that you receive after executing *Create new payment session request* request. Needed URL will be specified in `links.self`
    @objc public convenience init(listResultURL: URL) {
        let sharedTranslationProvider = SharedTranslationProvider()
        let connection = URLSessionConnection()

        self.init(listResultURL: listResultURL, connection: connection, sharedTranslationProvider: sharedTranslationProvider)
    }

    init(listResultURL: URL, connection: Connection, sharedTranslationProvider: SharedTranslationProvider) {
        sessionService = PaymentSessionService(paymentSessionURL: listResultURL, connection: connection, localizationProvider: sharedTranslationProvider)
        self.sharedTranslationProvider = sharedTranslationProvider
        router = List.Router(paymentServicesFactory: sessionService.paymentServicesFactory)

        super.init(nibName: nil, bundle: nil)

        viewManager.vc = self
        stateManager.vc = self
        operationResultHandler.delegate = self
        sessionService.delegate = self
        router.rootViewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Overrides

extension PaymentListViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        viewManager.configureMainView()
        navigationItem.largeTitleDisplayMode = .never

        // If view was presented modally show Cancel button
        if navigationController == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidPress))
        }

        loadPaymentSession()
    }

    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        methodsTableView?.reloadData()
    }
}

extension PaymentListViewController {
    func loadPaymentSession() {
        stateManager.viewState = .loading
        sessionService.loadPaymentSession()
    }

    fileprivate func show(paymentNetworks: [PaymentNetwork], animated: Bool) {
        do {
            let inputViewController = try router.present(paymentNetworks: paymentNetworks, animated: animated)
            inputViewController.delegate = operationResultHandler
        } catch {
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            dismiss(with: .failure(errorInfo))
        }
    }

    fileprivate func show(registeredAccount: RegisteredAccount, animated: Bool) {
        do {
            let inputViewController = try router.present(registeredAccount: registeredAccount, animated: animated)
            inputViewController.delegate = operationResultHandler
        } catch {
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            dismiss(with: .failure(errorInfo))
        }
    }

    @objc fileprivate func cancelButtonDidPress() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PaymentSessionServiceDelegate

extension PaymentListViewController: PaymentSessionServiceDelegate {
    func paymentSessionService(loadingDidCompleteWith result: Load<PaymentSession, ErrorInfo>) {
        self.title = self.sharedTranslationProvider.translation(forKey: "paymentpage.title")

        switch result {
        case .failure(let errorInfo):
            // If it is a communication failure show an alert with a retry option
            if case .COMMUNICATION_FAILURE = Interaction.Reason(rawValue: errorInfo.interaction.reason) {
                var alert = UIAlertController.AlertError(for: errorInfo, translator: sharedTranslationProvider)
                alert.actions = [
                    .init(label: .retry, style: .default) { [loadPaymentSession] _ in
                        loadPaymentSession()
                    },
                    .init(label: .cancel, style: .cancel) { [dismiss] _ in
                        dismiss(.failure(errorInfo))
                    }
                ]
                stateManager.viewState = .failure(alert)
            // In case of other errors just route the error to a merchant
            } else {
                dismiss(with: .failure(errorInfo))
            }
        case .loading:
            stateManager.viewState = .loading
        case .success(let session):
            stateManager.viewState = .success(session)
        }
    }

    func paymentSessionService(shouldSelect network: PaymentNetwork) {
        DispatchQueue.main.async {
            self.show(paymentNetworks: [network], animated: false)
        }
    }
}

// MARK: - ListTableControllerDelegate

extension PaymentListViewController: ListTableControllerDelegate {
    var downloadProvider: DataDownloadProvider { sessionService.downloadProvider }

    func didSelect(paymentNetworks: [PaymentNetwork]) {
        show(paymentNetworks: paymentNetworks, animated: true)
    }

    func didSelect(registeredAccount: RegisteredAccount) {
        show(registeredAccount: registeredAccount, animated: true)
    }
}

// MARK: - NetworkOperationResultHandler

// Received response from InputViewController
extension PaymentListViewController: OperationResultHandlerDelegate {
    func present(error: UIAlertController.AlertError) {
        stateManager.viewState = .failure(error)
    }

    /// Dismiss view controller and send result to a merchant
    func dismiss(with result: Result<OperationResult, ErrorInfo>) {
        let paymentResult = PaymentResult(operationResult: result)
        delegate?.paymentService(didReceivePaymentResult: paymentResult, viewController: self)
    }
}

extension CGFloat {
    static var rowHeight: CGFloat { return 64 }
}
#endif
