#if canImport(UIKit)
import UIKit

private struct UIConstant {
    static let defaultSpacing: CGFloat = 8
}

extension Input.Table {
    class LogoTextCell: UITableViewCell, DequeueableTableCell {
        
    }
}

extension Input.Table.LogoTextCell {
    func configure(with model: Input.Field.LogoText) {
        let image: UIImage?
        if let imageData = model.logoData {
            image = UIImage(data: imageData)
        } else {
            image = nil
        }
        
        imageView?.image = image
        textLabel?.text = model.label
    }
}
#endif
