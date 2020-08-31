#if canImport(UIKit)
import UIKit
import SafariServices

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

        var safariViewController: SFSafariViewController?

        weak var delegate: PaymentServiceDelegate?

        private init(header: CellRepresentable, smartSwitch: SmartSwitch.Selector, paymentServiceFactory: PaymentServicesFactory) {
            self.paymentController = .init(paymentServiceFactory: paymentServiceFactory)
            self.networks = smartSwitch.networks
            self.header = header
            self.smartSwitch = smartSwitch
            self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: tableController.flowLayout)

            super.init(nibName: nil, bundle: nil)

            paymentController.delegate = self

            tableController.setModel(network: smartSwitch.selected.network, header: header)

            stateManager = .init(viewController: self)

            self.scrollView = collectionView
            tableController.delegate = self
        }

        convenience init(for paymentNetworks: [PaymentNetwork], paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer()
            let networks = try paymentNetworks.map { try transformer.transform(paymentNetwork: $0) }
            let smartSwitch = try SmartSwitch.Selector(networks: networks)

            let header: CellRepresentable
            if paymentNetworks.count == 1, let network = paymentNetworks.first {
                header = Input.TextHeader(logo: network.logo?.value, label: network.label)
            } else {
                header = Input.ImagesHeader(for: networks)
            }

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory)

            // Placeholder translation suffixer
            for field in transformer.verificationCodeFields {
                field.keySuffixer = self
            }

            self.title = smartSwitch.selected.network.translation.translation(forKey: "networks.form.default.title")
        }

        convenience init(for registeredAccount: RegisteredAccount, paymentServiceFactory: PaymentServicesFactory) throws {
            let transformer = ModelTransformer()
            let network = try transformer.transform(registeredAccount: registeredAccount)
            let smartSwitch = SmartSwitch.Selector(network: network)
            let header = Input.TextHeader(from: registeredAccount)

            self.init(header: header, smartSwitch: smartSwitch, paymentServiceFactory: paymentServiceFactory)

            // Placeholder translation suffixer
            for field in transformer.verificationCodeFields {
                field.keySuffixer = self
            }

            self.title = registeredAccount.translation.translation(forKey: "accounts.form.default.title")
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Overrides

extension Input.ViewController {
    var hasInputFields: Bool { !smartSwitch.selected.network.uiModel.inputFields.isEmpty }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = .themedTint

        tableController.collectionView = self.collectionView
        tableController.configure()

        configure(collectionView: collectionView)

        collectionView.layoutIfNeeded()
        setPreferredContentSize()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: AssetProvider.iconClose, style: .plain, target: self, action: #selector(dismissView))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addKeyboardFrameChangesObserver()
        tableController.becomeFirstResponder()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if #available(iOS 11.0, *) {
            // In iOS11 insets are adjusted by `viewLayoutMarginsDidChange`
        } else {
            updateCollectionViewInsets()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardFrameChangesObserver()
    }

    @available(iOS 11.0, *)
    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        updateCollectionViewInsets()
    }

    fileprivate func updateCollectionViewInsets(adjustBottomInset: CGFloat = 0) {
        var newInset = UIEdgeInsets(top: view.layoutMargins.top, left: view.layoutMargins.left, bottom: view.layoutMargins.bottom + adjustBottomInset, right: view.layoutMargins.right)
        collectionView.contentInset = newInset

        if #available(iOS 11.0, *) {
            newInset.left = view.safeAreaInsets.left
            newInset.right = view.safeAreaInsets.right
        } else {
            newInset.left = 0
            newInset.right = 0
        }

        collectionView.scrollIndicatorInsets = newInset
    }
}

extension Input.ViewController {
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View configurator

extension Input.ViewController {
    fileprivate func configure(collectionView: UICollectionView) {
        collectionView.tintColor = view.tintColor
        collectionView.backgroundColor = .themedBackground

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}

// MARK: - InputValueChangesListener

extension Input.ViewController: InputTableControllerDelegate {
    func submitPayment() {
        stateManager.state = .paymentSubmission
        paymentController.submitPayment(for: smartSwitch.selected.network)
    }

    // MARK: Navigation bar shadow

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Control behaviour of navigation bar's shadow line
        guard let navigationController = self.navigationController else { return }

        let insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = scrollView.safeAreaInsets
        } else {
            insets = scrollView.contentInset
        }

        let yOffset = scrollView.contentOffset.y + insets.top

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
            case .generic: imagesHeaderModel.networks = self.networks
            case .specific(let specificNetwork): imagesHeaderModel.networks = [specificNetwork]
            }
        }

        tableController.setModel(network: newSelection.network, header: header)
    }
}

// MARK: - ModifableInsetsOnKeyboardFrameChanges

extension Input.ViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView? { collectionView }

    func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIView.AnimationOptions) {
        guard scrollViewToModify != nil else { return }

        if navigationController?.modalPresentationStyle == .custom {
            return
        }

        var adjustedHeight = height

        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            adjustedHeight -= tabBarHeight
        } else if let toolbarHeight = navigationController?.toolbar.frame.height, navigationController?.isToolbarHidden == false {
            adjustedHeight -= toolbarHeight
        }

        if #available(iOS 11.0, *) {
            adjustedHeight -= view.safeAreaInsets.bottom
        }

        if adjustedHeight < 0 { adjustedHeight = 0 }

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: { [self] in
            self.updateCollectionViewInsets(adjustBottomInset: adjustedHeight)
        })
    }
}

// MARK: - VerificationCodeTranslationKeySuffixer
extension Input.ViewController: VerificationCodeTranslationKeySuffixer {
    var suffixKey: String {
        switch smartSwitch.selected {
        case .generic: return "generic"
        case .specific: return "specific"
        }
    }
}

extension Input.ViewController: PaymentControllerDelegate {
    func paymentController(paymentCompleteWith result: PaymentResult) {
        DispatchQueue.main.async { [weak self] in
            self?.safariViewController?.dismiss(animated: true, completion: {
                self?.safariViewController = nil
            })

            self?.navigationController?.dismiss(animated: true, completion: nil)
            self?.delegate?.paymentService(didReceivePaymentResult: result)
        }
    }

    func paymentController(paymentFailedWith error: Error, withResult result: PaymentResult, isRetryable: Bool) {
        let onErrorAlertDismissBlock = { [weak self] in
            if isRetryable {
                self?.stateManager.state = .inputFieldsPresentation
                return
            }

            self?.navigationController?.dismiss(animated: true, completion: nil)
            self?.delegate?.paymentService(didReceivePaymentResult: result)
        }

        DispatchQueue.main.async { [weak self] in
            let changeStateBlock = {
                self?.safariViewController = nil
                self?.stateManager.state = .error(error, isRetryable: isRetryable, onDismissBlock: onErrorAlertDismissBlock)
            }

            if let svc = self?.safariViewController {
                svc.dismiss(animated: true, completion: changeStateBlock)
            } else {
                changeStateBlock()
            }
        }
    }

    func paymentController(presentURL url: URL) {
        DispatchQueue.main.async {
            let safariVC = SFSafariViewController(url: url)
            self.safariViewController = safariVC
            self.navigationController?.present(safariVC, animated: true, completion: nil)
        }
    }
}
#endif
