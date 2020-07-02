import UIKit

extension Input.Table {
    final class FlowLayout: UICollectionViewFlowLayout {
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map { $0.copy() } as? [UICollectionViewLayoutAttributes]
            layoutAttributesObjects?.forEach({ layoutAttributes in
                if layoutAttributes.representedElementCategory == .cell {
                    if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
                        layoutAttributes.frame = newFrame
                    }
                }
            })
            return layoutAttributesObjects
        }

        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            guard let collectionView = collectionView else {
                return nil
            }
            
            guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
                return nil
            }

            layoutAttributes.frame.origin.x = sectionInset.left
            
            let safeAreaWidth: CGFloat = collectionView.frame.width
            
            layoutAttributes.frame.size.width = safeAreaWidth - collectionView.contentInset.left - collectionView.contentInset.right
            
            return layoutAttributes
        }
    }
}
