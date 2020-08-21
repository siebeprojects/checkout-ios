#if canImport(UIKit)
import UIKit

extension List {
    @objc public final class ViewController: UIViewController {
        weak var scrollView: UIScrollView?
        weak var methodsTableView: UITableView?
        weak var activityIndicator: UIActivityIndicatorView?
        weak var errorAlertController: UIAlertController?

        let configuration: PaymentListParameters
        let sessionService: PaymentSessionService
        fileprivate(set) var tableController: List.Table.Controller?
        let sharedTranslationProvider: SharedTranslationProvider
        fileprivate let router: List.Router

        /// TODO: Migrate to separate State manager
        fileprivate var viewState: Load<PaymentSession, Error> = .loading {
            didSet { changeState(to: viewState) }
        }

        lazy private(set) var slideInPresentationManager = SlideInPresentationManager()

        /// - Parameter tableConfiguration: settings for a payment table view, if not specified defaults will be used
        /// - Parameter listResultURL: URL that you receive after executing *Create new payment session request* request. Needed URL will be specified in `links.self`
        @objc public convenience init(tableConfiguration: PaymentListParameters = DefaultPaymentListParameters(), listResultURL: URL) {
            let sharedTranslationProvider = SharedTranslationProvider()
            let connection = URLSessionConnection()

            self.init(tableConfiguration: tableConfiguration, listResultURL: listResultURL, connection: connection, sharedTranslationProvider: sharedTranslationProvider)
        }

        init(tableConfiguration: PaymentListParameters, listResultURL: URL, connection: Connection, sharedTranslationProvider: SharedTranslationProvider) {
            sessionService = PaymentSessionService(paymentSessionURL: listResultURL, connection: connection, localizationProvider: sharedTranslationProvider)
            configuration = tableConfiguration
            self.sharedTranslationProvider = sharedTranslationProvider
            router = List.Router(paymentServicesFactory: sessionService.paymentServicesFactory)

            super.init(nibName: nil, bundle: nil)
            
            router.rootViewController = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension List.ViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

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

    @objc private func cancelButtonDidPress() {
        dismiss(animated: true, completion: nil)
    }

    func loadPaymentSession() {
        viewState = .loading

        sessionService.loadPaymentSession(
            loadDidComplete: { [weak self] session in
                DispatchQueue.main.async {
                    self?.title = self?.sharedTranslationProvider.translation(forKey: "paymentpage.title")
                    self?.viewState = session
                }
            },
            shouldSelect: { [weak self] network in
                DispatchQueue.main.async {
                    self?.show(paymentNetworks: [network], animated: false)
                }
            }
        )
    }
    
    private func requireOperationType() throws -> ListResult.OperationType {
        guard case let .success(session) = self.viewState else {
            throw InternalError(description: "Incorrect state, unable to present")
        }
        
        guard let operationType = ListResult.OperationType(rawValue: session.operationType) else {
            throw InternalError(description: "Unknown operation type: %@", session.operationType)
        }
        
        return operationType
    }

    fileprivate func show(paymentNetworks: [PaymentNetwork], animated: Bool) {
        do {
            let inputViewController = try router.present(paymentNetworks: paymentNetworks, operationType: requireOperationType(), animated: animated)
            inputViewController.delegate = self
        } catch {
            viewState = .failure(error)
        }
    }

    fileprivate func show(registeredAccount: RegisteredAccount, animated: Bool) {
        do {
            let inputViewController = try router.present(registeredAccount: registeredAccount, operationType: requireOperationType(), animated: animated)
            inputViewController.delegate = self
        } catch {
            viewState = .failure(error)
        }
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

        let localizedError: LocalizedError
        if let error = error as? LocalizedError {
            localizedError = error
        } else {
            let text: String = sharedTranslationProvider.translation(forKey: TranslationKey.errorText.rawValue)
            localizedError = PaymentError(localizedDescription: text, underlyingError: nil)
        }

        let title: String = sharedTranslationProvider.translation(forKey: TranslationKey.errorTitle.rawValue)
        let controller = UIAlertController(title: title, message: localizedError.localizedDescription, preferredStyle: .alert)

        // Add retry button if needed
        if let networkError = error.asNetworkError {
            controller.message = networkError.localizedDescription
            let retryLabel: String = sharedTranslationProvider.translation(forKey: TranslationKey.retryLabel.rawValue)
            let retryAction = UIAlertAction(title: retryLabel, style: .default) { [weak self] _ in
                self?.loadPaymentSession()
            }
            controller.addAction(retryAction)
        }

        // Cancel
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { [weak self] _ in
            // Dimiss or pop back on error
            if self?.navigationController == nil {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        controller.addAction(cancelAction)

        self.present(controller, animated: true, completion: nil)
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

        if #available(iOS 11.0, *) {
            methodsTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        // Use that to remove extra spacing at top
        methodsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))

        methodsTableView.isScrollEnabled = false

        configuration.customize?(tableView: methodsTableView)

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

extension List.ViewController: ListTableControllerDelegate {
    var downloadProvider: DataDownloadProvider { sessionService.downloadProvider }

    func didSelect(paymentNetworks: [PaymentNetwork]) {
        show(paymentNetworks: paymentNetworks, animated: true)
    }

    func didSelect(registeredAccount: RegisteredAccount) {
        show(registeredAccount: registeredAccount, animated: true)
    }
}

extension List.ViewController: PaymentServiceDelegate {
    public func paymentService(didReceivePaymentResult paymentResult: PaymentResult) {
        switch Interaction.Code(rawValue: paymentResult.interaction.code) {
        case .TRY_OTHER_ACCOUNT, .TRY_OTHER_NETWORK, .RELOAD:
            loadPaymentSession()
        default:
            // RETRY was handled by `Input.ViewController`
            navigationController?.popViewController(animated: true)
        }
    }

    func paymentController(paymentSucceedWith result: OperationResult?) {
        navigationController?.popViewController(animated: true)
    }
}

extension CGFloat {
    static var rowHeight: CGFloat { return 64 }
}
#endif
