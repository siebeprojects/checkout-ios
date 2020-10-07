import UIKit
import Foundation

extension Input {
    final class ImagesHeader {
        var networks: [Network] = .init()
        var isEnabled: Bool = true

        init() {}

        convenience init(for networks: [Input.Network]) {
            self.init()
            self.networks = networks
        }
    }
}

extension Input.ImagesHeader: CellRepresentable {
    var cellType: (UICollectionViewCell & DequeueableCell).Type { Input.Table.ImagesView.self }

    func configure(cell: UICollectionViewCell) {
        guard let imagesView = cell as? Input.Table.ImagesView else { return }
        imagesView.configure(with: self)
    }
}
