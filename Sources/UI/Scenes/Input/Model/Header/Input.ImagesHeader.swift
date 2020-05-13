import UIKit
import Foundation

extension Input {
    final class ImagesHeader {
        var networks: [Network] = .init()

        init() {}
        
        convenience init(for networks: [Input.Network]) {
            self.init()
            self.setNetworks(networks)
        }
        
        func setNetworks(_ networks: [Input.Network]) {
            self.networks = networks
        }
    }
}

extension Input.ImagesHeader: CollectionViewRepresentable {
    func dequeueReusableSupplementaryView(for collectionView: UICollectionView, ofKind kind: String, for indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(Input.Table.ImagesView.self, ofKind: kind, for: indexPath)
    }
    
    func configure(view: UICollectionReusableView) throws {
        guard let imagesView = view as? Input.Table.ImagesView else {
            throw errorForIncorrectView(view)
        }

        imagesView.configure(with: self)
    }
}
