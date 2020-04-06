import UIKit

extension Input.Table {
    class ImageViewCell: UICollectionViewCell {
        let imageView: UIImageView
        
        override init(frame: CGRect) {
            imageView = .init(frame: frame)
            
            super.init(frame: frame)
            
            contentView.addSubview(imageView)

            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
