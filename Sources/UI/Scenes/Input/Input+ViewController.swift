#if canImport(UIKit)
import UIKit

extension Input {
    class ViewController: UIViewController {
        let networks: [Network]
        
        private let tableController: TableController
        private let tableView = UITableView(frame: .zero, style: .grouped)
        
        /// - Throws: `InternalError` if `networks` array is empty
        init(for networks: [PaymentNetwork]) throws {
            self.networks = networks.map { Transformer.transform(paymentNetwork: $0) }
            
            guard let firstNetwork = self.networks.first else {
                throw InternalError(description: "Tried to initialize with 0 PaymentNetworks")
            }
            
            guard self.networks.isInputFieldsGroupable() else {
                throw InternalError(description: "Input fields are not groupable: %@", objects: self.networks)
            }
            
            self.tableController = .init(for: firstNetwork, tableView: tableView)
            
            super.init(nibName: nil, bundle: nil)
            
            tableController.inputChangesListener = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Input.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(tableView: tableView)
                
        let payButton = makePayButton(using: tableController.network.translation)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: payButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardFrameChangesObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.cellForRow(at: [0, 0])?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardFrameChangesObserver()
    }
    
    private func configure(tableView: UITableView) {
        tableView.register(Input.TextFieldViewCell.self)
        tableView.dataSource = tableController
        tableView.delegate = tableController
        tableView.tableHeaderView = makeTableViewHeader(for: tableController.network)
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.systemBackground
        } else {
            tableView.backgroundColor = UIColor.white
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PaymentListTableViewCell.self)
        tableView.rowHeight = 50
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    private func makeTableViewHeader(for network: Input.Network) -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 200))
        contentView.preservesSuperviewLayoutMargins = true
        
        // Image
        let imageView = UIImageView(image: network.logo)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 8*4),
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 8*4),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8*4),
        ])
        
        let imageContentViewTrailing = imageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -8*4)
        imageContentViewTrailing.priority = .defaultHigh
        imageContentViewTrailing.isActive = true
        
        return contentView
    }
    
    private func makePayButton(using translation: TranslationProvider) -> UIButton {
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 17
        button.backgroundColor = view.tintColor
        let title = NSAttributedString(string: translation.translation(forKey: "button.charge.label"), attributes: [
            .font: UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize),
            .foregroundColor: UIColor.white
        ])
        
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(dismissNavigation), for: .touchUpInside)
        
        let desiredWidth = button.intrinsicContentSize.width
        button.widthAnchor.constraint(equalToConstant: desiredWidth + 30).isActive = true
        
        return button
    }
    
    @objc private func dismissNavigation() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension Input.ViewController: InputValueChangesListener {
    /// Switch to a new network if needed (based on input field's type and value).
    /// - Note: called by `TableController`
    func valueDidChange(for field: InputField) {
        // React only on account numbers
        guard let accountNumber = field as? Input.AccountNumberInputField else { return }
        guard let value = accountNumber.value else { return }
        
        let switchSelector = Input.SmartSwitch.Selector(networks: networks, currentNetwork: tableController.network)
        guard let newNetwork = switchSelector.select(usingAccountNumber: value) else { return }
        
        // Continue only if the new network is not equal to current
        guard newNetwork != self.tableController.network else { return }
        
        // Save previously entered input values and move to the new model
        switchSelector.moveInputValues(to: newNetwork)
                
        DispatchQueue.main.async {
            // UI changes
            self.replaceCurrentNetwork(with: newNetwork)
        }
    }
    
    private func replaceCurrentNetwork(with newNetwork: Input.Network) {
        tableController.network = newNetwork
        tableView.tableHeaderView = makeTableViewHeader(for: newNetwork)
    }
}

extension Input.ViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView? { tableView }
}
#endif
