#if canImport(UIKit)
import Foundation
import UIKit

/// Cell for payment method list
/// - Note: set `cellIndex`
final class PaymentListDetailedLabelCell: PaymentListBorderedCell, DequeueableTableCell {
    weak var primaryLabel: UILabel?
    weak var secondaryLabel: UILabel?
    private weak var logosStackView: ImageStackView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addContentViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(_ images: [UIImage]) {
        logosStackView?.images = images
        logosStackView?.layoutIfNeeded()
    }
}

// MARK: - Content views

extension PaymentListDetailedLabelCell {
    fileprivate func addContentViews() {
        let primaryLabel = UILabel(frame: .zero)
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryLabel.font = .preferredFont(forTextStyle: .body)
        primaryLabel.textColor = .text
        contentView.addSubview(primaryLabel)
        self.primaryLabel = primaryLabel
        
        let secondaryLabel = UILabel(frame: .zero)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = .preferredFont(forTextStyle: .footnote)
        secondaryLabel.textColor = .detailedText
        contentView.addSubview(secondaryLabel)
        self.secondaryLabel = secondaryLabel
    
        let logosStackView = ImageStackView(frame: .zero, imagesTintColor: .detailedText)
        logosStackView.translatesAutoresizingMaskIntoConstraints = false
        logosStackView.axis = .horizontal
        logosStackView.distribution = .fillProportionally
        logosStackView.spacing = .defaultSpacing
        contentView.addSubview(logosStackView)
        self.logosStackView = logosStackView
        
        // UI
        
        let logoStackViewTralingConstraint = logosStackView.trailingAnchor.constraint(equalTo: primaryLabel.leadingAnchor, constant: -2 * CGFloat.defaultSpacing)
        
        logosStackView.setContentHuggingPriority(.required, for: .horizontal)
        logosStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        primaryLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        primaryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        secondaryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            primaryLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.leadingAnchor, constant: .labelToLeftSeparatorSpacing),
            primaryLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
            primaryLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: .verticalSpacing / -2),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            secondaryLabel.leadingAnchor.constraint(equalTo: logosStackView.trailingAnchor, constant: .defaultSpacing * 2),
            secondaryLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: .verticalSpacing / 2),
            secondaryLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            logosStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            logosStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            logosStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            logoStackViewTralingConstraint
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static var labelToLeftSeparatorSpacing: CGFloat { return 68 }
    static var defaultSpacing: CGFloat { return 8 }
    static var verticalSpacing: CGFloat { return 4 }
}
#endif
