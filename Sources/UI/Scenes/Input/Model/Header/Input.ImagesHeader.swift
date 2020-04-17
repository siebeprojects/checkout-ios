import UIKit
import Foundation

extension Input {
    final class ImagesHeader {
        let logosData: [Data]

        private init(logosData: [Data]) {
            self.logosData = logosData
        }

        /// Initializes header with transformed label and detailed label from `maskedAccount` data.
        convenience init(from networks: [Input.Network]) {
            let logosData = networks.compactMap { $0.logoData }

            self.init(logosData: logosData)
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
