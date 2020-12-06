// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import UIKit

extension List {
    @objc public final class ViewController: UIViewController {
        weak var scrollView: UIScrollView?
        weak var methodsTableView: UITableView?
        weak var activityIndicator: UIActivityIndicatorView?
        weak var errorAlertController: UIAlertController?

        let sessionService: PaymentSessionService
        fileprivate(set) var tableController: List.Table.Controller?
        let sharedTranslationProvider: SharedTranslationProvider
        fileprivate let router: List.Router

        public weak var delegate: PaymentDelegate?

        /// TODO: Migrate to separate State manager
        fileprivate var viewState: Load<PaymentSession, Error> = .loading {
            didSet { changeState(to: viewState) }
        }

        lazy private(set) var slideInPresentationManager = SlideInPresentationManager()

        /// - Parameter tableConfiguration: settings for a payment table view, if not specified defaults will be used
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

            sessionService.delegate = self
            router.rootViewController = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Overrides

extension List.ViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themedBackground
        navigationItem.largeTitleDisplayMode = .never

        // If view was presented modally show Cancel button
        if navigationController == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidPress))
        }

        loadPaymentSession()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableController?.viewDidLayoutSubviews()
    }

    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        methodsTableView?.reloadData()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.paymentViewControllerWillDismiss()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.paymentViewControllerDidDismiss()
    }
}

extension List.ViewController {
    func loadPaymentSession() {
        viewState = .loading
        sessionService.loadPaymentSession()
    }

    fileprivate func show(paymentNetworks: [PaymentNetwork], animated: Bool) {
        do {
            let inputViewController = try router.present(paymentNetworks: paymentNetworks, animated: animated)
            inputViewController.delegate = self
        } catch {
            viewState = .failure(error)
        }
    }

    fileprivate func show(registeredAccount: RegisteredAccount, animated: Bool) {
        do {
            let inputViewController = try router.present(registeredAccount: registeredAccount, animated: animated)
            inputViewController.delegate = self
        } catch {
            viewState = .failure(error)
        }
    }

    @objc fileprivate func cancelButtonDidPress() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View state management

extension List.ViewController {
    fileprivate func changeState(to state: Load<PaymentSession, Error>) {
        switch state {
        case .success(let session):
            do {
                activityIndicator(isActive: false)
                try showPaymentMethods(for: session)
                presentError(nil)
            } catch {
                viewState = .failure(error)
            }
        case .loading:
            do {
                activityIndicator(isActive: true)
                try showPaymentMethods(for: nil)
                presentError(nil)
            } catch {
                viewState = .failure(error)
           }
        case .failure(let error):
            activityIndicator(isActive: true)
            try? showPaymentMethods(for: nil)
            presentError(error)
        }
    }

    private func showPaymentMethods(for session: PaymentSession?) throws {
        guard let session = session else {
            // Hide payment methods
            scrollView?.removeFromSuperview()
            scrollView = nil

            methodsTableView?.removeFromSuperview()
            methodsTableView = nil
            tableController = nil

            return
        }

        // Show payment methods
        let scrollView = addScrollView()
        self.scrollView = scrollView

        let methodsTableView = addMethodsTableView(to: scrollView)
        self.methodsTableView = methodsTableView

        let tableController = try List.Table.Controller(session: session, translationProvider: sharedTranslationProvider)
        tableController.tableView = methodsTableView
        tableController.delegate = self
        self.tableController = tableController

        methodsTableView.dataSource = tableController.dataSource
        methodsTableView.delegate = tableController
        methodsTableView.prefetchDataSource = tableController

        methodsTableView.invalidateIntrinsicContentSize()
    }

    private func activityIndicator(isActive: Bool) {
        if isActive == false {
            // Hide activity indicator
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
            return
        }

        if self.activityIndicator != nil { return }

        // Show activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.activityIndicator = activityIndicator
        activityIndicator.startAnimating()
    }

    private func presentError(_ error: Error?) {
        guard let error = error else {
            // Dismiss alert controller
            errorAlertController?.dismiss(animated: true, completion: nil)
            return
        }

        let errorDismissBlock = {
            if self.navigationController == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }

        // Present a custom error for network failures
        if let networkError = error.asNetworkError {
            let builtError = UIAlertController.PreparedError(title: nil, message: networkError.localizedDescription, dismissBlock: errorDismissBlock)

            let alertController = builtError.createAlertController(translator: sharedTranslationProvider)
            let retryLabel: String = sharedTranslationProvider.translation(forKey: TranslationKey.retryLabel.rawValue)
            let retryAction = UIAlertAction(title: retryLabel, style: .default) { [weak self] _ in
                self?.loadPaymentSession()
            }
            alertController.addAction(retryAction)

            self.errorAlertController = alertController
            present(alertController, animated: true, completion: nil)
        }

        var localizedError: UIAlertController.PreparedError

        if let uiPreparedError = error as? UIAlertController.PreparedError {
            // For prebuilt errors don't do any transformations
            localizedError = uiPreparedError
        } else {
            // Some unknown error, just show a generic error
            localizedError = UIAlertController.PreparedError(for: error, translator: sharedTranslationProvider)
        }

        localizedError.dismissBlock = errorDismissBlock

        // Create and show error controller
        let alertController = localizedError.createAlertController(translator: sharedTranslationProvider)
        self.errorAlertController = alertController
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Table View UI

extension List.ViewController {
    fileprivate func addScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceVertical = true
        scrollView.preservesSuperviewLayoutMargins = true
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        return scrollView
    }

    fileprivate func addMethodsTableView(to superview: UIView) -> UITableView {
        let methodsTableView = List.Table.TableView(frame: CGRect.zero, style: .grouped)
        methodsTableView.separatorStyle = .none
        methodsTableView.backgroundColor = .clear
        methodsTableView.rowHeight = .rowHeight
        methodsTableView.contentInsetAdjustmentBehavior = .never

        // Use that to remove extra spacing at top
        methodsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))

        methodsTableView.isScrollEnabled = false

        methodsTableView.translatesAutoresizingMaskIntoConstraints = false
        methodsTableView.register(List.Table.SingleLabelCell.self)
        methodsTableView.register(List.Table.DetailedLabelCell.self)
        superview.addSubview(methodsTableView)

        let topPadding: CGFloat = 30

        NSLayoutConstraint.activate([
            methodsTableView.leadingAnchor.constraint(equalTo: superview.layoutMarginsGuide.leadingAnchor),
            methodsTableView.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor),
            methodsTableView.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor, constant: topPadding),
            methodsTableView.centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        ])

        let trailingConstraint = methodsTableView.trailingAnchor.constraint(equalTo: superview.layoutMarginsGuide.trailingAnchor)
        trailingConstraint.priority = .defaultHigh
        trailingConstraint.isActive = true

        return methodsTableView
    }
}

// MARK: - PaymentSessionServiceDelegate

extension List.ViewController: PaymentSessionServiceDelegate {
    func paymentSessionService(loadingDidCompleteWith result: Load<PaymentSession, Error>) {
        self.title = self.sharedTranslationProvider.translation(forKey: "paymentpage.title")

        switch result {
        case .failure(let error):
            if let errorInfo = error as? ErrorInfo {
                dismiss(withOperationResult: .failure(errorInfo))
            } else {
                let abortInteraction = Interaction(code: .ABORT, reason: .CLIENTSIDE_ERROR)
                let customErrorInfo = CustomErrorInfo(resultInfo: error.localizedDescription, interaction: abortInteraction, underlyingError: error)
                dismiss(withOperationResult: .failure(customErrorInfo))
            }
        default:
            self.viewState = result
        }
    }

    func paymentSessionService(shouldSelect network: PaymentNetwork) {
        DispatchQueue.main.async {
            self.show(paymentNetworks: [network], animated: false)
        }
    }
}

// MARK: - ListTableControllerDelegate

extension List.ViewController: ListTableControllerDelegate {
    var downloadProvider: DataDownloadProvider { sessionService.downloadProvider }

    func didSelect(paymentNetworks: [PaymentNetwork]) {
        show(paymentNetworks: paymentNetworks, animated: true)
    }

    func didSelect(registeredAccount: RegisteredAccount) {
        show(registeredAccount: registeredAccount, animated: true)
    }
}

// MARK: - NetworkOperationResultHandler

extension List.ViewController: NetworkOperationResultHandler {
    func paymentController(didReceiveOperationResult result: Result<OperationResult, ErrorInfo>, for network: Input.Network) {
        switch Interaction.Code(rawValue: result.interaction.code) {
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK:
            // Display a popup containing the title/text correlating to the INTERACTION_CODE and INTERACTION_REASON (see https://www.optile.io/de/opg#292619) with an OK button. 
            var uiPreparedError: UIAlertController.PreparedError
            do {
                uiPreparedError = try UIAlertController.PreparedError(for: result.interaction, translator: network.translation)
            } catch {
                uiPreparedError = UIAlertController.PreparedError(for: error, translator: network.translation)
            }

            uiPreparedError.dismissBlock = {
                self.loadPaymentSession()
            }

            viewState = .failure(uiPreparedError)
        case .RELOAD:
            // Reload the LIST object and re-render the payment method list accordingly, don't show error alert.
            loadPaymentSession()
        default:
            dismiss(withOperationResult: result)
        }
    }

    /// Dismiss view controller and send result to a merchant
    private func dismiss(withOperationResult result: Result<OperationResult, ErrorInfo>) {
        let paymentResult = PaymentResult(operationResult: result)
        delegate?.paymentService(didReceivePaymentResult: paymentResult)
        navigationController?.popViewController(animated: true)
    }
}

extension CGFloat {
    static var rowHeight: CGFloat { return 64 }
}
#endif
