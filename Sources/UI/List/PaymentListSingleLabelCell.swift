#if canImport(UIKit)
import Foundation
import UIKit

/// Cell for payment method list
/// - Note: set `cellIndex`
final class PaymentListTableViewCell: PaymentListBorderedCell, DequeueableTableCell {
    weak var networkLabel: UILabel?
    weak var networkLogoView: UIImageView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addContentViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Content views

extension PaymentListTableViewCell {
    fileprivate func addContentViews() {
        let networkLabel = UILabel(frame: .zero)
        networkLabel.translatesAutoresizingMaskIntoConstraints = false
        networkLabel.font = .preferredFont(forTextStyle: .body)
        networkLabel.textColor = .text
        contentView.addSubview(networkLabel)
        self.networkLabel = networkLabel
        
        let networkLogoView = UIImageView(image: nil)
        networkLogoView.translatesAutoresizingMaskIntoConstraints = false
        networkLogoView.contentMode = .scaleAspectFit
        contentView.addSubview(networkLogoView)
        self.networkLogoView = networkLogoView
        
        NSLayoutConstraint.activate([
            networkLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: .labelToLeftSeparatorSpacing),
            networkLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: .defaultSpacing),
            networkLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -.defaultSpacing),
            networkLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            networkLogoView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            networkLogoView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            networkLogoView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            networkLogoView.trailingAnchor.constraint(equalTo: networkLabel.leadingAnchor, constant: -2 * CGFloat.defaultSpacing)
        ])
        
        networkLogoView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        networkLogoView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}

// MARK: - Constants

private extension CGFloat {
    static var labelToLeftSeparatorSpacing: CGFloat { return 68 }
    static var defaultSpacing: CGFloat { return 8 }
}
#endif
