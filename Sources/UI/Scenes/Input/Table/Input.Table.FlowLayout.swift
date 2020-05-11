import UIKit

extension Input.Table {
    final class FlowLayout: UICollectionViewFlowLayout {
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
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
            
            let safeAreaWidth: CGFloat
            if #available(iOS 11.0, *) {
                safeAreaWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width
            } else {
                safeAreaWidth = 0
            }
            
            layoutAttributes.frame.size.width = safeAreaWidth - sectionInset.left - sectionInset.right
            
            return layoutAttributes
        }
    }
}
