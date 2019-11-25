#if canImport(UIKit)
import UIKit

class InputViewController: UIViewController {
    // MARK: Model
    var network: PaymentNetwork
    
    init(for paymentNetwork: PaymentNetwork) {
        self.network = paymentNetwork
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = network.label
        view.backgroundColor = UIColor.white
    }
}
#endif
