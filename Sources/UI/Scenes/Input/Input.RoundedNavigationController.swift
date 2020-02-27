import UIKit

extension Input {
    class RoundedNavigationController: UINavigationController {
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.tintColor = .tintColor
            
            // Remove shadow line and background
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
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
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat { return 12 }
}
