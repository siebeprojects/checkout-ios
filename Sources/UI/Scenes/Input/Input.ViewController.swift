#if canImport(UIKit)
import UIKit

// MARK: Initializers

extension Input {
    class ViewController: SlideInViewController {
        let networks: [Network]
        
        private let tableController: Table.Controller
        private let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), style: .grouped)
        fileprivate let smartSwitch: SmartSwitch.Selector
        
        init(for paymentNetworks: [PaymentNetwork]) throws {
            let transfomer = Field.Transformer()
            networks = paymentNetworks.map { transfomer.transform(paymentNetwork: $0) }
            smartSwitch = try .init(networks: self.networks)
            tableController = .init(for: smartSwitch.selected.network, tableView: tableView)
            
            guard networks.isInputFieldsGroupable() else {
                throw InternalError(description: "Input fields are not groupable: %@", objects: self.networks)
            }
            
            super.init(nibName: nil, bundle: nil)
            
            self.scrollView = tableView
            
            tableController.inputChangesListener = self
            
            // Placeholder translation suffixer
            for field in transfomer.verificationCodeFields {
                field.keySuffixer = self
            }
        }
        
        init(for registeredAccount: RegisteredAccount) {
            let transfomer = Field.Transformer()
            let network = transfomer.transform(registeredAccount: registeredAccount)
            networks = [network]
            smartSwitch = .init(network: network)
            tableController = .init(for: smartSwitch.selected.network, tableView: tableView)
            
            super.init(nibName: nil, bundle: nil)
            
            self.scrollView = tableView
            
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
        
        configure(tableView: tableView)
        
        tableView.layoutIfNeeded()
        setPreferredContentSize()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: AssetProvider.iconClose, style: .plain, target: self, action: #selector(dismissView))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardFrameChangesObserver()
        tableView.cellForRow(at: [0, 0])?.becomeFirstResponder()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardFrameChangesObserver()
    }
}

extension Input.ViewController {
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - View configurator

extension Input.ViewController {
    fileprivate func configure(tableView: UITableView) {
        tableView.register(Input.Table.TextFieldViewCell.self)
        tableView.dataSource = tableController
        tableView.delegate = tableController
        tableView.tableHeaderView = makeTableViewHeader(for: tableController.network)
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.systemBackground
        } else {
            tableView.backgroundColor = UIColor.white
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(List.Table.SingleLabelCell.self)
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}

// MARK: - View constructors

extension Input.ViewController {
    private func makeTableViewHeader(for network: Input.Network) -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 200))
        contentView.preservesSuperviewLayoutMargins = true
        
        // Image
        let imageView = UIImageView(image: network.logo)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

        let imageViewMargin: CGFloat = 8*4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: imageViewMargin),
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: imageViewMargin),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -imageViewMargin),
        ])
        
        let imageContentViewTrailing = imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -imageViewMargin)
        imageContentViewTrailing.priority = .defaultHigh
        imageContentViewTrailing.isActive = true
        
        return contentView
    }
    
    @objc private func payButtonDidTap() {
        tableController.validateFields(option: .fullCheck)
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
            self.replaceCurrentNetwork(with: newSelection.network)
        }
    }
    
    private func replaceCurrentNetwork(with newNetwork: Input.Network) {
        tableController.network = newNetwork
        tableView.tableHeaderView = makeTableViewHeader(for: newNetwork)
    }
}

// MARK: - ModifableInsetsOnKeyboardFrameChanges

extension Input.ViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView? { tableView }
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
