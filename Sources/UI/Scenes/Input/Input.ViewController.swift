#if canImport(UIKit)
import UIKit

// MARK: Initializers

extension Input {
    class ViewController: SlideInViewController {
        let networks: [Network]

        private let tableController: Table.Controller
        fileprivate let smartSwitch: SmartSwitch.Selector
        fileprivate let headerModel: ViewRepresentable?

        private let collectionView: UICollectionView
        
        init(for paymentNetworks: [PaymentNetwork]) throws {
            let transfomer = ModelTransformer()
            networks = paymentNetworks.map { transfomer.transform(paymentNetwork: $0) }
            headerModel = Input.ImagesHeader(for: networks)
            smartSwitch = try .init(networks: self.networks)
            tableController = .init(for: smartSwitch.selected.network)
            collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: tableController.flowLayout)

            super.init(nibName: nil, bundle: nil)

            self.scrollView = collectionView

            tableController.inputChangesListener = self

            // Placeholder translation suffixer
            for field in transfomer.verificationCodeFields {
                field.keySuffixer = self
            }
        }

        init(for registeredAccount: RegisteredAccount) {
            let transfomer = ModelTransformer()
            let network = transfomer.transform(registeredAccount: registeredAccount)
            networks = [network]
            headerModel = Input.TextHeader(from: registeredAccount)
            smartSwitch = .init(network: network)
            tableController = .init(for: smartSwitch.selected.network)
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

        configure(collectionView: collectionView)
        
        collectionView.layoutIfNeeded()
        setPreferredContentSize()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: AssetProvider.iconClose, style: .plain, target: self, action: #selector(dismissView))
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let navigationController = self.navigationController else { return }

        let insets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            insets = scrollView.safeAreaInsets
        } else {
            insets = scrollView.contentInset
        }

        let yOffset = scrollView.contentOffset.y + insets.top

        // If scroll view is on top
        if yOffset == 0 {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardFrameChangesObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // FIXME: No header in collection view
//        updateTableViewHeaderFrame()
    }
}

extension Input.ViewController {
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View configurator

extension Input.ViewController {
    // FIXME: No header in UICollectionView
//    fileprivate func updateTableViewHeaderFrame() {
//        guard let headerView = collectionView.tableHeaderView else { return }
//
//        let headerViewSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        let headerViewFrame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: headerViewSize.height))
//        headerView.frame = headerViewFrame
//    }

    fileprivate func configure(collectionView: UICollectionView) {
        tableController.configure()
        
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
        tableController.network = newSelection.network
        // FIXME: No header in CollectionView
//        if let imagesHeader = headerModel as? Input.ImagesHeader, let tableHeaderView = collectionView.tableHeaderView {
//            switch newSelection {
//            case .generic: imagesHeader.setNetworks(self.networks)
//            case .specific(let specificNetwork): imagesHeader.setNetworks([specificNetwork])
//            }
//
//            try? imagesHeader.configure(view: tableHeaderView)
//        }
    }
}

// MARK: - ModifableInsetsOnKeyboardFrameChanges

extension Input.ViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView? { collectionView }

    func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIView.AnimationOptions) {
         guard let scrollViewToModify = scrollViewToModify else { return }

         if navigationController?.modalPresentationStyle == .custom {
            scrollViewToModify.contentInset = .zero
            scrollViewToModify.scrollIndicatorInsets = .zero

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

         UIView.animate(withDuration: animationDuration, animations: {
             let newInsets = UIEdgeInsets(top: 0, left: 0, bottom: adjustedHeight, right: 0)

             scrollViewToModify.contentInset = newInsets
             scrollViewToModify.scrollIndicatorInsets = newInsets
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
