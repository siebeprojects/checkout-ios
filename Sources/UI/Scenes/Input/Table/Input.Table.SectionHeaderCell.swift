import UIKit

private extension CGFloat {
    static var height: CGFloat { return 4 }
}

extension Input.Table {
    class SectionHeaderCell: UITableViewCell, DequeueableTableCell {
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            NSLayoutConstraint.activate([
                contentView.heightAnchor.constraint(equalToConstant: .height)
            ])
         }
         
         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    }
}
