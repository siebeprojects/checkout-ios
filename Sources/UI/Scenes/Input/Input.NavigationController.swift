import UIKit

extension Input {
    class NavigationController: UINavigationController {
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.tintColor = .tintColor
            if #available(iOS 13.0, *) {
                navigationBar.barTintColor = .systemBackground
            } else {
                navigationBar.barTintColor = .white
            }
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            // Round top corners
            let corners: UIRectCorner = [.topLeft, .topRight]
            
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: .cornerRadius, height: .cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = view.bounds
            maskLayer.path = path.cgPath
            view.layer.mask = maskLayer
        }
        
        override var shouldAutorotate: Bool {
            if modalPresentationStyle == .custom {
                // MVP solution, we block autorotation in the input form because it leads to hard debuggable UI issue
                // and it is a very rare situation
                // Bug: f keyboard is present and device was rotated input form may disappear
                return false
            } else {
                return true
            }
        }
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat { return 12 }
}
