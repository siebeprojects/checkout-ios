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
        
        title = network.label
        view.backgroundColor = UIColor.white
        
        let tableView = addTableView()
        tableView.register(InputTableViewCell.self)
        tableView.dataSource = tableController
        tableView.delegate = tableController
        self.tableView = tableView
    }
    
    private func addTableView() -> UITableView {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)

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
}
#endif
