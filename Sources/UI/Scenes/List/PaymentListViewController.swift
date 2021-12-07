// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

@objc public final class PaymentListViewController: UIViewController {
    weak var methodsTableView: UITableView?
    weak var activityIndicator: UIActivityIndicatorView?
    weak var errorAlertController: UIAlertController?

    let sessionService: PaymentSessionService
    let sharedTranslationProvider: SharedTranslationProvider
    fileprivate let router: List.Router

    @objc public weak var delegate: PaymentDelegate?

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

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
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
        if #available(iOS 14.0, *) {
            logger.info("Loading payment session...")
        }

        stateManager.viewState = .loading
        sessionService.loadPaymentSession()
    }

    fileprivate func show(paymentNetworks: [UIModel.PaymentNetwork], context: UIModel.PaymentContext, animated: Bool) {
        do {
            if #available(iOS 14.0, *) {
                let paymentNetworkNames = paymentNetworks.map { $0.label }
                logger.info("Requested to show payment networks: \(paymentNetworkNames, privacy: .private)")
            }
            let inputViewController = try router.present(paymentNetworks: paymentNetworks, context: context, animated: animated)
            inputViewController.delegate = operationResultHandler
        } catch {
            if let errorInfo = error as? ErrorInfo {
                dismiss(with: .failure(errorInfo))
            } else {
                let customErrorInfo = CustomErrorInfo.createClientSideError(from: error)
                dismiss(with: .failure(customErrorInfo))
            }
        }
    }

    fileprivate func show(registeredAccount: UIModel.RegisteredAccount, context: UIModel.PaymentContext, animated: Bool) {
        do {
            if #available(iOS 14.0, *) {
                logger.debug("Requested to show a registered account for the network: \(registeredAccount.networkLabel, privacy: .private)")
            }
            let inputViewController = try router.present(registeredAccount: registeredAccount, context: context, animated: animated)
            inputViewController.delegate = operationResultHandler
        } catch {
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            dismiss(with: .failure(errorInfo))
        }
    }

    fileprivate func show(presetAccount: UIModel.PresetAccount, context: UIModel.PaymentContext, animated: Bool) {
        do {
            if #available(iOS 14.0, *) {
                logger.debug("Requested to show a preset account for the network: \(presetAccount.networkLabel, privacy: .private)")
            }
            let inputViewController = try router.present(presetAccount: presetAccount, context: context, animated: animated)
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
    func paymentSessionService(didReceiveResult result: Result<UIModel.PaymentSession, ErrorInfo>) {
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
        case .success(let session):
            stateManager.viewState = .networksList(session)
        }
    }

    func paymentSessionService(shouldSelect network: UIModel.PaymentNetwork, context: UIModel.PaymentContext) {
        DispatchQueue.main.async {
            self.show(paymentNetworks: [network], context: context, animated: false)
        }
    }
}

// MARK: - ListTableControllerDelegate

extension PaymentListViewController: ListTableControllerDelegate {
    var downloadProvider: DataDownloadProvider { sessionService.downloadProvider }

    func didSelect(paymentNetworks: [UIModel.PaymentNetwork], context: UIModel.PaymentContext) {
        show(paymentNetworks: paymentNetworks, context: context, animated: true)
    }

    func didSelect(registeredAccount: UIModel.RegisteredAccount, context: UIModel.PaymentContext) {
        show(registeredAccount: registeredAccount, context: context, animated: true)
    }

    func didSelect(presetAccount: UIModel.PresetAccount, context: UIModel.PaymentContext) {
        show(presetAccount: presetAccount, context: context, animated: true)
    }

    func didRefreshRequest() {
        loadPaymentSession()
    }
}

// MARK: - NetworkOperationResultHandler

// Received response from InputViewController
extension PaymentListViewController: OperationResultHandlerDelegate {
    func present(error: UIAlertController.AlertError) {
        let alertController = error.createAlertController(translator: sharedTranslationProvider)
        present(alertController, animated: true, completion: nil)
    }

    /// Dismiss view controller and send result to a merchant
    func dismiss(with result: Result<OperationResult, ErrorInfo>) {
        if #available(iOS 14.0, *) {
            if case let .failure(error) = result {
                logger.error("⛔️ Dismissing list view with error: \(error.localizedDescription, privacy: .private)")
            }
        }

        let paymentResult = PaymentResult(operationResult: result)
        delegate?.paymentService(didReceivePaymentResult: paymentResult, viewController: self)
    }
}

extension CGFloat {
    static var rowHeight: CGFloat { return 64 }
}

extension PaymentListViewController: Loggable {
    var logCategory: String { "ListScene" }
}
