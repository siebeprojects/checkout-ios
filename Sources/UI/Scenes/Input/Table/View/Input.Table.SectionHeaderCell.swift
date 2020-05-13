import UIKit

extension Input.Table {
    class SectionHeaderCell: UICollectionReusableView, DequeueableCell {
        struct Constant {
            static var height: CGFloat { return 4 }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            let heightConstraint = heightAnchor.constraint(equalToConstant: Constant.height)
            heightConstraint.priority = .defaultHigh
            heightConstraint.isActive = true
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
        
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            layoutIfNeeded()
            layoutAttributes.frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
        }
    }
}
