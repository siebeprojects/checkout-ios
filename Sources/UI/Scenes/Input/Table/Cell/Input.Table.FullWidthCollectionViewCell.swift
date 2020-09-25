import UIKit

extension Input.Table {
    class FullWidthCollectionViewCell: UICollectionViewCell {
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
            let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
            let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
            autoLayoutAttributes.frame = autoLayoutFrame
            return autoLayoutAttributes
        }
    }
}
