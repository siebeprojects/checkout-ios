import UIKit

extension Input.Table {
    class FullWidthCollectionViewCell: UICollectionViewCell {
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            layoutIfNeeded()
            layoutAttributes.frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            return layoutAttributes
        }
    }
}
