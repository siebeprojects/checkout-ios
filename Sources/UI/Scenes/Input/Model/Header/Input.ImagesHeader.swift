import UIKit
import Foundation

extension Input {
    final class ImagesHeader {
        var logosData: [Data] = .init()

        init() {}
        
        convenience init(for networks: [Input.Network]) {
            self.init()
            self.setNetworks(networks)
        }
        
        func setNetworks(_ networks: [Input.Network]) {
            self.logosData = networks.compactMap { $0.logoData }
        }
    }
}

extension Input.ImagesHeader: ViewRepresentable {
    func configure(view: UIView) throws {
        guard let imagesView = view as? Input.Table.ImagesView else {
            throw errorForIncorrectView(view)
        }

        imagesView.configure(with: self)
    }

    var configurableViewType: UIView.Type {
        return Input.Table.ImagesView.self
    }
}
