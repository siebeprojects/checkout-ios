#if canImport(UIKit)

import UIKit

@objc public class PaymentNavigationController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = .navigationBarTintColor
        navigationBar.tintColor = .white
        navigationBar.barStyle = .black
    }
}

#endif
