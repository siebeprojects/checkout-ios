// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

// MARK: Initializers

extension Input {
    class ViewController: SlideInViewController {
        let networks: [Network]
        let header: CellRepresentable
        let tableController = Table.Controller()
        let smartSwitch: SmartSwitch.Selector

        let collectionView: UICollectionView
        fileprivate private(set) var stateManager: StateManager!
        fileprivate let paymentController: PaymentController!

        fileprivate let browserController: BrowserController

        weak var delegate: NetworkOperationResultHandler?

        lazy var activityIndicatorView: UIActivityIndicatorView = { UIActivityIndicatorView(style: .gray) }()
        lazy var deleteBarButton: UIBarButtonItem = {
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBarButtonDidTap(_:)))
        }()

        private init(header: CellRepresentable, smartSwitch: SmartSwitch.Selector, paymentServiceFactory: PaymentServicesFactory, context: PaymentContext) {
            self.paymentController = .init(paymentServiceFactory: paymentServiceFactory, listOperationType: context.listOperationType.rawValue)
            self.networks = smartSwitch.networks
            self.header = header
            self.smartSwitch = smartSwitch
            self.browserController = BrowserController(smartSwitch: smartSwitch)
            self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: tableController.layoutController.flowLayout)

            super.init(nibName: nil, bundle: nil)

            browserController.presenter = self
            paymentController.delegate = self
            paymentController.operationResultHandler.delegate = self

            tableController.setModel(network: smartSwitch.selected.network, header: header)

            stateManager = .init(viewController: self)

            self.scrollView = collectionView
            tableController.delegate = self
            tableController.modalPresenter = self
        }

        convenience init(for paymentNetworks: [PaymentNetwork], context: PaymentContext, paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer(paymentContext: context)
            let networks = try paymentNetworks.map { try transformer.transform(paymentNetwork: $0) }
            let smartSwitch = try SmartSwitch.Selector(networks: networks)

            let header: CellRepresentable
            if paymentNetworks.count == 1, let network = paymentNetworks.first {
                header = Input.TextHeader(logo: network.logo?.value, label: network.label)
            } else {
                header = Input.ImagesHeader(for: networks)
            }

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory, context: context)

            self.title = smartSwitch.selected.network.translation.translation(forKey: "networks.form.default.title")
        }

        convenience init(for registeredAccount: RegisteredAccount, context: PaymentContext, paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer(paymentContext: context)
            let network = try transformer.transform(registeredAccount: registeredAccount)
            let smartSwitch = try SmartSwitch.Selector(networks: [network])
            let header = Input.TextHeader(from: registeredAccount)

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory, context: context)

            self.title = registeredAccount.translation.translation(forKey: "accounts.form.default.title")
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Overrides

extension Input.ViewController {
    /// Return a boolean with information if view controller has the main section with user-input fields
    var hasInputFields: Bool {
        guard let inputElements = smartSwitch.selected.network.uiModel.inputSections[.inputElements] else { return false }
        return !inputElements.inputFields.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = .themedTint

        tableController.collectionView = self.collectionView
        tableController.configure()

        configure(collectionView: collectionView)

        collectionView.layoutIfNeeded()
        setPreferredContentSize()

        configureNavigationBar()

        tableController.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addKeyboardFrameChangesObserver()
        browserController.subscribeForNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardFrameChangesObserver()
        browserController.unsubscribeFromNotification()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in self.collectionView.collectionViewLayout.invalidateLayout() },
            completion: { _ in }
        )
    }
}

// MARK: - Initial configuration

extension Input.ViewController {
    fileprivate func configure(collectionView: UICollectionView) {
        collectionView.tintColor = view.tintColor
        collectionView.backgroundColor = .themedBackground
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.preservesSuperviewLayoutMargins = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    fileprivate func configureNavigationBar() {
        let closeButton: UIBarButtonItem

        if #available(iOS 13.0, *) {
            closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissView))
        } else {
            closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))
        }

        navigationItem.setLeftBarButton(closeButton, animated: false)

        if networks.count == 1, let network = networks.first, network.isDeletable {
            navigationItem.setRightBarButton(deleteBarButton, animated: false)
        }
    }
}

// MARK: - Navigation Bar configurator

extension Input.ViewController {
    @objc private func deleteBarButtonDidTap(_ sender: UIBarButtonItem) {
        let translator = smartSwitch.selected.network.translation
        let accountLabel = smartSwitch.selected.network.uiModel.maskedAccountLabel ?? smartSwitch.selected.network.uiModel.networkLabel

        var alert = DeletionAlert(translator: translator, accountLabel: accountLabel)
        alert.setDeleteAction { _ in
            self.stateManager.state = .deletion
            self.paymentController.delete(network: self.smartSwitch.selected.network)
        }

        present(alert.createAlertController(), animated: true, completion: nil)
    }

    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - InputTableControllerDelegate

extension Input.ViewController: InputTableControllerDelegate {
    func submitPayment() {
        stateManager.state = .paymentSubmission
        paymentController.submitPayment(for: smartSwitch.selected.network)
    }

    // Navigation bar shadow
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Control behaviour of navigation bar's shadow line
        guard let navigationController = self.navigationController else { return }

        let yOffset = scrollView.contentOffset.y + scrollView.safeAreaInsets.top

        // If scroll view is on top
        if yOffset <= 0 {
            // Hide shadow line
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        } else {
            if navigationController.navigationBar.shadowImage != nil {
                // Show shadow line
                navigationController.navigationBar.setBackgroundImage(nil, for: .default)
                navigationController.navigationBar.shadowImage = nil
            }
        }
    }

    // MARK: InputFields changes

    /// Switch to a new network if needed (based on input field's type and value).
    /// - Note: called by `TableController`
    func valueDidChange(for field: InputField) {
        // React only on account number changes
        guard let accountNumberField = field as? Input.Field.AccountNumber else { return }

        let accountNumber = accountNumberField.value

        let previousSelection = smartSwitch.selected
        let newSelection = smartSwitch.select(usingAccountNumber: accountNumber)

        // Change UI only if the new network is not equal to current
        guard newSelection != previousSelection else { return }

        DispatchQueue.main.async {
            // UI changes
            self.replaceCurrentNetwork(with: newSelection)
        }
    }

    private func replaceCurrentNetwork(with newSelection: Input.SmartSwitch.Selector.DetectedNetwork) {
        if let imagesHeaderModel = header as? Input.ImagesHeader {
            switch newSelection {
            case .generic:
                if #available(iOS 14.0, *) {
                    logger.debug("SmartSwitch replacing model with a generic network")
                }

                imagesHeaderModel.networks = self.networks
            case .specific(let specificNetwork):
                if #available(iOS 14.0, *) {
                    logger.debug("SmartSwitch replacing model with the specific network: \(specificNetwork.uiModel.networkLabel, privacy: .private)")
                }

                imagesHeaderModel.networks = [specificNetwork]
            }
        }

        tableController.setModel(network: newSelection.network, header: header)
    }
}

// MARK: - ModifableInsetsOnKeyboardFrameChanges

extension Input.ViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView? { collectionView }
}

// MARK: - InputPaymentControllerDelegate

extension Input.ViewController: InputPaymentControllerDelegate {
    /// Route result to the next view controller
    func paymentController(route result: Result<OperationResult, ErrorInfo>, for request: OperationRequest) {
        browserController.dismissBrowserViewController()
        dismiss(animated: true, completion: {
            self.delegate?.paymentController(didReceiveOperationResult: result, for: request, network: self.smartSwitch.selected.network)
        })
    }

    func paymentController(didFailWith error: ErrorInfo, for request: OperationRequest?) {
        // Try to dismiss safari VC (if exists)
        browserController.dismissBrowserViewController()

        // Construct error
        let translator = smartSwitch.selected.network.translation
        var alertError = UIAlertController.AlertError(for: error, translator: translator)

        // Unlock input fields after error alert dismissal
        alertError.actions = [
            .init(label: .retry, style: .default) { [submitPayment] _ in
                submitPayment()
            },
            .init(label: .cancel, style: .cancel, handler: { [self] _ in
                dismiss(animated: true) {
                    self.delegate?.paymentController(didReceiveOperationResult: .failure(error), for: request, network: self.smartSwitch.selected.network)
                }
            })
        ]

        // Show an error
        stateManager.state = .error(alertError)
    }

    /// Show an error and return to input fields editing state
    func paymentController(inputShouldBeChanged error: ErrorInfo) {
        // Try to dismiss safari VC (if exists)
        browserController.dismissBrowserViewController()

        // Construct error
        let translator = smartSwitch.selected.network.translation
        var alertError = UIAlertController.AlertError(for: error, translator: translator)

        // Unlock input fields after error alert dismissal
        alertError.actions = [
            .init(label: .ok, style: .default) { _ in
                self.stateManager.state = .inputFieldsPresentation
            }
        ]

        // Show an error
        stateManager.state = .error(alertError)
    }

    func paymentController(presentURL url: URL) {
        browserController.presentBrowser(with: url)
    }
}

extension Input.ViewController: ModalPresenter {}

extension Input.ViewController: Loggable {
    var logCategory: String { "InputScene" }
}
