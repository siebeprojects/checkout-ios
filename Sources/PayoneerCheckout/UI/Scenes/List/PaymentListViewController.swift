// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Risk
import Logging
import Networking
import Payment

final class PaymentListViewController: UIViewController, ModalPresenter {
    weak var methodsTableView: UITableView?
    weak var activityIndicator: UIActivityIndicatorView?
    weak var errorAlertController: UIAlertController?

    let sessionService: PaymentSessionService
    let sharedTranslationProvider: SharedTranslationProvider

    private weak var delegate: PaymentDelegate?

    let stateManager = StateManager()
    let viewManager = ViewManager()
    private let requestResultHandler: RequestResultHandler

    /// - Parameter listResultURL: URL that you receive after executing *Create new payment session request* request. Needed URL will be specified in `links.self`
    convenience init(listResultURL: URL, paymentServices: [PaymentService.Type], riskService: RiskService, delegate: PaymentDelegate) {
        let sharedTranslationProvider = SharedTranslationProvider()
        let connection = URLSessionConnection()

        self.init(listResultURL: listResultURL, connection: connection, sharedTranslationProvider: sharedTranslationProvider, paymentServices: paymentServices, riskService: riskService, delegate: delegate)
    }

    init(listResultURL: URL, connection: Connection, sharedTranslationProvider: SharedTranslationProvider, paymentServices: [PaymentService.Type], riskService: RiskService, delegate: PaymentDelegate) {
        self.sessionService = PaymentSessionService(
            paymentSessionURL: listResultURL,
            connection: connection,
            localizationProvider: sharedTranslationProvider,
            paymentServices: paymentServices,
            riskService: riskService
        )
        self.sharedTranslationProvider = sharedTranslationProvider
        self.delegate = delegate
        self.requestResultHandler = RequestResultHandler(localizer: sharedTranslationProvider)

        super.init(nibName: nil, bundle: nil)

        viewManager.vc = self
        stateManager.vc = self
        requestResultHandler.delegate = self
        sessionService.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Overrides

extension PaymentListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        navigationItem.largeTitleDisplayMode = .never

        if #available(iOS 13.0, *) {
            navigationController?.isModalInPresentation = true
        }

        if #available(iOS 13.0, *) {
            let closeButtonImage = UIImage(systemName: "xmark")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .semibold))
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(closeButtonAction))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeButtonAction))
        }

        viewManager.configureMainView()

        loadPaymentSession()
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        methodsTableView?.reloadData()
    }
}

extension PaymentListViewController {
    func loadPaymentSession() {
        if #available(iOS 14.0, *) {
            logger.info("Loading payment session...")
        }

        stateManager.viewState = .listLoading
        sessionService.loadPaymentSession()
    }

    fileprivate func show(paymentNetworks: [UIModel.PaymentNetwork], context: UIModel.PaymentContext, animated: Bool) {
        do {
            if #available(iOS 14.0, *) {
                let paymentNetworkNames = paymentNetworks.map { $0.label }
                logger.info("Requested to show payment networks: \(paymentNetworkNames, privacy: .private)")
            }

            let inputViewController = try Input.ViewController(for: paymentNetworks, context: context, paymentServiceFactory: sessionService.paymentServicesFactory)
            inputViewController.listRequestResultHandler = requestResultHandler
            show(inputViewController, sender: nil)

        } catch {
            if let errorInfo = error as? ErrorInfo {
                dismiss(with: .failure(errorInfo))
            } else {
                let customErrorInfo = CustomErrorInfo.createClientSideError(from: error)
                dismiss(with: .failure(customErrorInfo))
            }
        }
    }

    fileprivate func show(registeredAccount: UIModel.RegisteredAccount, context: UIModel.PaymentContext) {
        do {
            if #available(iOS 14.0, *) {
                logger.debug("Requested to show a registered account for the network: \(registeredAccount.networkLabel, privacy: .private)")
            }

            let inputViewController = try Input.ViewController(for: registeredAccount, context: context, paymentServiceFactory: sessionService.paymentServicesFactory)
            inputViewController.listRequestResultHandler = requestResultHandler
            show(inputViewController, sender: nil)

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

            let inputViewController = try Input.ViewController(for: presetAccount, context: context, paymentServiceFactory: sessionService.paymentServicesFactory)
            inputViewController.listRequestResultHandler = requestResultHandler
            show(inputViewController, sender: nil)

        } catch {
            let errorInfo = CustomErrorInfo.createClientSideError(from: error)
            dismiss(with: .failure(errorInfo))
        }
    }

    @objc private func closeButtonAction() {
        dismiss(animated: true)
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
        show(registeredAccount: registeredAccount, context: context)
    }

    func didSelect(presetAccount: UIModel.PresetAccount, context: UIModel.PaymentContext) {
        // Response for a preset account should be created locally (PCX-996) without displaying input view controller (PCX-2409).
        let builder = PresetResponseBuilder()
        let localReponse = builder.createResponse(for: presetAccount.apiModel)
        dismiss(with: localReponse)
    }

    func didRefreshRequest() {
        loadPaymentSession()
    }
}

// MARK: - NetworkOperationResultHandler

// Received response from InputViewController
extension PaymentListViewController: ListRequestResultHandlerDelegate {
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

        let result = CheckoutResult(result: result)
        delegate?.paymentService(didReceiveResult: result)
    }
}

extension CGFloat {
    static var rowHeight: CGFloat { return 64 }
}

extension PaymentListViewController: Loggable {
    public var logCategory: String { "ListScene" }
}
