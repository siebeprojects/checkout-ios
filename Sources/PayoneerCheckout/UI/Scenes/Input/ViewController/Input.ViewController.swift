// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Networking
import Logging

// MARK: Initializers

extension Input {
    class ViewController: UIViewController {
        let networks: [Network]
        let header: CellRepresentable
        let tableController = Table.Controller()
        let smartSwitch: SmartSwitch.Selector

        let collectionView: UICollectionView
        fileprivate private(set) var stateManager: StateManager!

        private let browserController: BrowserController

        private let requestSender: RequestSender
        private let requestResultHandler = RequestResultHandler()

        weak var listRequestResultHandler: PaymentListViewController.RequestResultHandler?

        lazy var activityIndicatorView: UIActivityIndicatorView = { UIActivityIndicatorView(style: .gray) }()
        lazy var deleteBarButton: UIBarButtonItem = {
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBarButtonDidTap(_:)))
        }()

        private init(header: CellRepresentable, smartSwitch: SmartSwitch.Selector, paymentServiceFactory: PaymentServicesFactory, context: UIModel.PaymentContext) {
            self.requestSender = RequestSender(paymentServiceFactory: paymentServiceFactory, riskService: context.riskService)
            self.networks = smartSwitch.networks
            self.header = header
            self.smartSwitch = smartSwitch
            self.browserController = BrowserController()
            self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: tableController.layoutController.flowLayout)

            super.init(nibName: nil, bundle: nil)

            browserController.presenter = self
            requestSender.delegate = requestResultHandler
            requestResultHandler.delegate = self

            tableController.setModel(network: smartSwitch.selected.network, header: header)

            stateManager = .init(viewController: self)

            tableController.delegate = self
            tableController.presenter = self
        }

        convenience init(for paymentNetworks: [UIModel.PaymentNetwork], context: UIModel.PaymentContext, paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer(paymentContext: context)
            let networks = try paymentNetworks.map { try transformer.transform(paymentNetwork: $0) }
            let smartSwitch = try SmartSwitch.Selector(networks: networks)

            let header: CellRepresentable
            if paymentNetworks.count == 1, let network = paymentNetworks.first {
                header = Input.TextHeader(logo: network.logo?.value, title: network.label)
            } else {
                header = Input.ImagesHeader(for: networks)
            }

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory, context: context)

            self.title = smartSwitch.selected.network.translation.translation(forKey: "networks.form.default.title")
        }

        convenience init(for registeredAccount: UIModel.RegisteredAccount, context: UIModel.PaymentContext, paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer(paymentContext: context)
            let network = try transformer.transform(registeredAccount: registeredAccount)
            let smartSwitch = try SmartSwitch.Selector(networks: [network])
            let header = Input.TextHeader(from: registeredAccount)

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory, context: context)

            header.translator = registeredAccount.translation
            header.presenter = self

            self.title = registeredAccount.translation.translation(forKey: "accounts.form.default.title")
        }

        convenience init(for presetAccount: UIModel.PresetAccount, context: UIModel.PaymentContext, paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer(paymentContext: context)
            let network = try transformer.transform(presetAccount: presetAccount)
            let smartSwitch = try SmartSwitch.Selector(networks: [network])
            let header = Input.TextHeader(from: presetAccount)

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory, context: context)

            header.translator = presetAccount.translation
            header.presenter = self

            self.title = presetAccount.translation.translation(forKey: "accounts.form.default.title")
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

        tableController.collectionView = self.collectionView
        tableController.configure()

        configure(collectionView: collectionView)

        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addKeyboardFrameChangesObserver()
        browserController.subscribeForNotification()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableController.becomeFirstResponder()
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
        collectionView.backgroundColor = CheckoutAppearance.shared.backgroundColor
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
        if networks.count == 1, let network = networks.first, network.isDeletable {
            navigationItem.rightBarButtonItem = deleteBarButton
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
            self.requestSender.delete(network: self.smartSwitch.selected.network)
        }

        present(alert.createAlertController(), animated: true, completion: nil)
    }
}

// MARK: - InputTableControllerDelegate

extension Input.ViewController: InputTableControllerDelegate {
    func submitPayment() {
        stateManager.state = .paymentSubmission
        requestSender.submitOperation(for: smartSwitch.selected.network)
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

extension Input.ViewController: InputRequestResultHandlerDelegate {
    /// Route result to the next view controller
    func requestHandler(route result: Result<OperationResult, ErrorInfo>, forRequestType requestType: RequestSender.RequestType) {
        navigationController?.popViewController(animated: true)

        listRequestResultHandler?.requestHandler(didReceiveResult: result, forRequestType: requestType)
    }

    func requestHandler(communicationFailedWith error: ErrorInfo, forRequestType requestType: RequestSender.RequestType) {
        // Construct error
        let translator = smartSwitch.selected.network.translation
        var alertError = UIAlertController.AlertError(for: error, translator: translator)

        // Unlock input fields after error alert dismissal
        alertError.actions = [
            .init(label: .retry, style: .default) { [submitPayment] _ in
                submitPayment()
            },
            .init(label: .cancel, style: .cancel) { _ in
                self.listRequestResultHandler?.requestHandler(didReceiveResult: .failure(error), forRequestType: requestType)
            }
        ]

        // Show an error
        stateManager.state = .error(alertError)
    }

    /// Show an error and return to input fields editing state
    func requestHandler(inputShouldBeChanged error: ErrorInfo) {
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

    func requestHandler(present viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true)
    }
}

extension Input.ViewController: ViewControllerPresenter {}

extension Input.ViewController: Loggable {
    var logCategory: String { "InputScene" }
}
