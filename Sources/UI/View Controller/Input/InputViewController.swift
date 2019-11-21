#if canImport(UIKit)
import UIKit

class InputViewController: UIViewController {
    // MARK: Model
    var network: PaymentNetwork
    
    private let tableController: InputTableController
    
    // MARK: UI
    private weak var tableView: UITableView?
    
    init(for paymentNetwork: PaymentNetwork) {
        self.network = paymentNetwork
        
        self.tableController = InputTableController(network: network)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = addTableView()
        tableView.register(TextFieldViewCell.self)
        tableView.dataSource = tableController
        tableView.delegate = tableController
        tableView.tableHeaderView = tableViewHeader()
        
        self.tableView = tableView
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: payButton())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardFrameChangesObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardFrameChangesObserver()
    }
    
    private func addTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
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

        return tableView
    }
    
    private func tableViewHeader() -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 200))
        contentView.preservesSuperviewLayoutMargins = true
        
        // Image
        let imageView: UIView
        if let image = network.logo?.image {
            imageView = UIImageView(image: image)
        } else {
            imageView = UIImageView(frame: .zero)
        }
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
                
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
    
    private func payButton() -> UIButton {
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 17
        button.backgroundColor = view.tintColor
        let title = NSAttributedString(string: network.translation.translation(forKey: "button.charge.label"), attributes: [
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

extension InputViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView? { tableView }
}
#endif
