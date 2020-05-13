import UIKit

/// Model that could configure view to represent itself.
protocol CollectionViewRepresentable {
    func dequeueReusableSupplementaryView(for collectionView: UICollectionView, ofKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView

    /// - Throws: `InternalError` if input view is not supported.
    func configure(view: UICollectionReusableView) throws
}

extension CollectionViewRepresentable {
    func errorForIncorrectView(_ view: UIView) -> InternalError {
        return InternalError(description: "Unable to configure unexpected view: %@", objects: view)
    }
}
