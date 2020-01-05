#if canImport(UIKit)
import Foundation
import UIKit

/// Cell with borders.
/// - Note: set `cellIndex`
class PaymentListBorderedCell: UITableViewCell {
    weak var outerView: UIView?
    weak var innerView: UIView?
    weak var separatorView: UIView?
    weak var separatorStickyConstraint: NSLayoutConstraint?
    
    /// Cell's position in a table, used for rounding correct corners
    var cellIndex: CellIndex = .middle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addBordersViews()
    }
    
    func viewDidLayoutSubviews() {
        guard let separatorView = self.separatorView else { return }
        guard let innerView = self.innerView, let outerView = self.outerView else { return }

        // Stick separator to top or bottom
        if let constraint = separatorStickyConstraint {
            separatorView.removeConstraint(constraint)
        }

        let constraint: NSLayoutConstraint
        switch cellIndex {
        case .first, .middle:
            constraint = separatorView.bottomAnchor.constraint(equalTo: outerView.bottomAnchor)
        case .last:
            constraint = separatorView.topAnchor.constraint(equalTo: outerView.topAnchor)
        }
        constraint.isActive = true
        self.separatorStickyConstraint = constraint
        
        // Round corners
        let corners: UIRectCorner
        
        switch cellIndex {
        case .first: corners = [.topLeft, .topRight]
        case .middle: corners = []
        case .last: corners = [.bottomLeft, .bottomRight]
        }

        for view in [innerView, outerView] {
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: .cornerRadius, height: .cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = view.bounds
            maskLayer.path = path.cgPath
            view.layer.mask = maskLayer
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Content views

extension PaymentListBorderedCell {
    /// Add border views.
    /// - Description: we create 2 rectangles, outer rectangle will have a border background color, inner background will have a normal background color and it will have 1px spacing between outer one. Result will be a border that we could round.
    // I think it's the best way to create a rounded border around section's content and use dynamic constraints instead of frame calculations. It's iOS10+ way, if requirements will be iOS11+ that could be done easier with `maskedCorners`.
    fileprivate func addBordersViews() {
        let outerView = UIView(frame: .zero)
        outerView.translatesAutoresizingMaskIntoConstraints = false
        outerView.backgroundColor = .border
        addSubview(outerView)
        sendSubviewToBack(outerView)
        self.outerView = outerView
        
        let innerView = UIView(frame: .zero)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.backgroundColor = .background
        outerView.addSubview(innerView)
        self.innerView = innerView
        
        let separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .separator
        outerView.addSubview(separatorView)
        self.separatorView = separatorView
        
        NSLayoutConstraint.activate([
            outerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerView.topAnchor.constraint(equalTo: topAnchor),
            outerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            outerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            innerView.leadingAnchor.constraint(equalTo: outerView.leadingAnchor, constant: 1),
            innerView.topAnchor.constraint(equalTo: outerView.topAnchor, constant: 1),
            innerView.bottomAnchor.constraint(equalTo: outerView.bottomAnchor, constant: -1),
            innerView.trailingAnchor.constraint(equalTo: outerView.trailingAnchor, constant: -1),
            
            separatorView.leadingAnchor.constraint(equalTo: outerView.leadingAnchor, constant: 1),
            separatorView.trailingAnchor.constraint(equalTo: outerView.trailingAnchor, constant: -1),
            separatorView.heightAnchor.constraint(equalToConstant: .separatorWidth)
        ])
    }
}

extension PaymentListBorderedCell {
    enum CellIndex {
        case first
        case middle
        case last
    }
}

// MARK: - Constants

private extension UIColor {
    class var border: UIColor {
        return UIColor(white: 224.0 / 255.0, alpha: 1.0)
    }
    
    class var separator: UIColor {
        return UIColor(white: 242.0 / 255.0, alpha: 1.0)
    }
    
    class var background: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
}

private extension CGFloat {
    static var separatorWidth: CGFloat { return 1 }
    static var cornerRadius: CGFloat { return 2 }
}
#endif
