import UIKit
import Foundation

extension Input {
    final class ImagesHeader {
        var networks: [Network] = .init()

        init() {}
        
        convenience init(for networks: [Input.Network]) {
            self.init()
            self.networks = networks
        }
    }
}

extension Input.ImagesHeader: CellRepresentable {
    func dequeueCell(for view: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return view.dequeueReusableCell(Input.Table.ImagesView.self, for: indexPath)
    }
    
    func configure(cell: UICollectionViewCell) {
        guard let imagesView = cell as? Input.Table.ImagesView else { return }
        imagesView.configure(with: self)
    }
    
    var estimatedHeightForRow: CGFloat {
        // FIXME: Deprecated method
        return 0
    }
}
