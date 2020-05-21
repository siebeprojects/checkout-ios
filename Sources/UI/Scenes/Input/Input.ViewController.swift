#if canImport(UIKit)
import UIKit

// MARK: Initializers

extension Input {
    class ViewController: SlideInViewController {
        let networks: [Network]
        let header: CellRepresentable
        
        private let tableController: Table.Controller
        fileprivate let smartSwitch: SmartSwitch.Selector

        private let collectionView: UICollectionView
        
        init(for paymentNetworks: [PaymentNetwork]) throws {
            let transformer = ModelTransformer()
            networks = paymentNetworks.map { transformer.transform(paymentNetwork: $0) }
            smartSwitch = try .init(networks: self.networks)
            header = Input.ImagesHeader(for: networks)
            tableController = .init(for: smartSwitch.selected.network, header: header)
            collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: tableController.flowLayout)

            super.init(nibName: nil, bundle: nil)

            self.scrollView = collectionView

            tableController.inputChangesListener = self

            // Placeholder translation suffixer
            for field in transformer.verificationCodeFields {
                field.keySuffixer = self
            }
        }

        init(for registeredAccount: RegisteredAccount) {
            let transfomer = ModelTransformer()
            let network = transfomer.transform(registeredAccount: registeredAccount)
            networks = [network]
            smartSwitch = .init(network: network)
            header = Input.TextHeader(from: registeredAccount)
            tableController = .init(for: smartSwitch.selected.network, header: header)
            collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: tableController.flowLayout)
            
            super.init(nibName: nil, bundle: nil)

            self.scrollView = collectionView

            tableController.inputChangesListener = self

            // Placeholder translation suffixer
            for field in transfomer.verificationCodeFields {
                field.keySuffixer = self
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Overrides

extension Input.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = networks.first?.translation.translation(forKey: LocalTranslation.inputViewTitle.rawValue)
        view.tintColor = .tintColor

        tableController.collectionView = self.collectionView
        tableController.scrollViewWillBeginDraggingBlock = scrollViewWillBeginDragging
        tableController.configure()

        configure(collectionView: collectionView)
        
        collectionView.layoutIfNeeded()
        setPreferredContentSize()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: AssetProvider.iconClose, style: .plain, target: self, action: #selector(dismissView))
    }

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
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor.systemBackground
        } else {
            collectionView.backgroundColor = UIColor.white
        }

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

extension Input.ViewController: InputValueChangesListener {
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
#endif
