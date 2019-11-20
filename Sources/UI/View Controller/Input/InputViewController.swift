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
        
//        title = network.label
        
        let tableView = addTableView()
        tableView.register(InputTableViewCell.self)
        tableView.dataSource = tableController
        tableView.delegate = tableController
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.systemBackground
        } else {
            tableView.backgroundColor = UIColor.white
        }
        self.tableView = tableView
        
        tableView.tableHeaderView = makeTableViewHeader()
        tableView.tableFooterView = makeTableViewFooter()
    }
    
    private func addTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PaymentListTableViewCell.self)
        tableView.estimatedRowHeight = 44
        
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        return tableView
    }
    
    private func makeTableViewHeader() -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 200))
        
        // Image Content View
        let imageContentView = UIView(frame: .zero)
        contentView.addSubview(imageContentView)
        if #available(iOS 13.0, *) {
//            imageContentView.backgroundColor = UIColor.systemGray6
        } else {
            imageContentView.backgroundColor = UIColor.systemGray
        }
        
        imageContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContentView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 2/3)
        ])
        
        let imageContentViewTrailing = imageContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        imageContentViewTrailing.priority = .defaultHigh
        imageContentViewTrailing.isActive = true
        
        // Image
        let imageView: UIImageView
        if let image = network.logo?.image {
            imageView = UIImageView(image: image)
        } else {
            imageView = UIImageView(frame: .zero)
        }
        imageContentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: imageContentView.layoutMarginsGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContentView.layoutMarginsGuide.centerYAnchor)
        ])
        
        // Title
        let title = UILabel(frame: .zero)
        contentView.addSubview(title)
        
        title.text = network.label
        title.textAlignment = .center
        if #available(iOS 11.0, *) {
            title.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
        } else {
            // Fallback on earlier versions
        }
        
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: imageContentView.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            title.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -24)
        ])
        
        let titleTrailing = title.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        titleTrailing.priority = .defaultHigh
        titleTrailing.isActive = true
        
        return contentView
    }
    
    private func makeTableViewFooter() -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 60))
        
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 10
        button.backgroundColor = view.tintColor
        let title = NSAttributedString(string: "Pay", attributes: [
            .font: UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .semibold),
            .foregroundColor: UIColor.white
        ])
        
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(dismissNavigation), for: .touchUpInside)
                
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        let trailing = button.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        trailing.priority = .defaultHigh
        trailing.isActive = true
        
        return contentView
    }
    
    @objc private func dismissNavigation() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
#endif
