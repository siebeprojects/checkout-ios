#if canImport(UIKit)
import UIKit

class InputTableViewCell: UITableViewCell, DequeueableTableCell {
    private weak var modelView: UIView?
    
    var model: ViewRepresentable! {
        didSet {
            configure(with: model)
        }
    }
    
    private func configure(with model: ViewRepresentable) {
        let view = model.createView()
        contentView.addSubview(view)
        self.modelView = view

        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            view.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        ])
    }
}
#endif
