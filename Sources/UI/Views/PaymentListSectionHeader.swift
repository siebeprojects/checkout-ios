#if canImport(UIKit)
import UIKit

class PaymentListSectionHeader: UIView {
    weak var textLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let textLabel = UILabel(frame: frame)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = .text
        textLabel.font = .preferredFont(forTextStyle: .footnote)
        
        addSubview(textLabel)
        self.textLabel = textLabel
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: .topPadding),
            textLabel.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CGFloat {
    static var topPadding: CGFloat { return 30 }
}
#endif
