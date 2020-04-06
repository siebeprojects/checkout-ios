#if canImport(UIKit)
import UIKit

extension Input.Table {
    class ImagesView: UIView {
        private let collectionView: ImagesCollectionView
        private let collectionViewFlow = UICollectionViewFlowLayout()
        fileprivate let collectionController = ImagesCollectionViewController()
        
        override init(frame: CGRect) {
            collectionView = .init(frame: frame, collectionViewLayout: collectionViewFlow)
            collectionView.isScrollEnabled = false
            
            super.init(frame: frame)
            
            collectionController.registerCells(for: collectionView)
            collectionView.delegate = collectionController
            collectionView.dataSource = collectionController
            collectionView.backgroundColor = .clear
            
            self.preservesSuperviewLayoutMargins = true
            
            self.addSubview(collectionView)
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                collectionView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Input.Table.SectionHeaderCell.Constant.height * 2),
                collectionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            ])
         }
        
        override func layoutSubviews() {
            collectionView.layoutSubviews()
            super.layoutSubviews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


extension Input.Table.ImagesView {
    func configure(with model: Input.ImagesHeader) {
        collectionController.dataSource = model.logosData.compactMap {
            UIImage(data: $0)
        }
    }
}
#endif
