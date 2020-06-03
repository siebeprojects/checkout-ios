import UIKit

extension Input.Table {
    class ImagesCollectionView: UICollectionView {
        override func reloadData() {
            super.reloadData()

            self.invalidateIntrinsicContentSize()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            invalidateIntrinsicContentSize()
        }

        override var intrinsicContentSize: CGSize {
            return collectionViewLayout.collectionViewContentSize
        }
    }
}
