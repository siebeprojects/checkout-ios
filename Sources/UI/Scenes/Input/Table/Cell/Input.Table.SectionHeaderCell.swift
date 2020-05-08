import UIKit

extension Input.Table {
    class SectionHeaderCell: UICollectionViewCell, DequeueableCell {
        struct Constant {
            static var height: CGFloat { return 4 }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            NSLayoutConstraint.activate([
                contentView.heightAnchor.constraint(equalToConstant: Constant.height)
            ])
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    }
}
