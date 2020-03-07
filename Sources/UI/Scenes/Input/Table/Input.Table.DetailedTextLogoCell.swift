import UIKit

private extension CGFloat {
    static let logoWidth: CGFloat = 40
    static let imageLabelSpacing: CGFloat = 16
}

extension Input.Table {
    class DetailedTextLogoCell: UITableViewCell, DequeueableTableCell {
        private let label: UILabel
        private let detailedLabel: UILabel
        private let logoView: UIImageView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            label = .init(frame: .zero)
            detailedLabel = .init(frame: .zero)
            logoView = .init(frame: .zero)
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.accessoryType = .checkmark

            label.font = .preferredFont(forTextStyle: .body)
            
            contentView.addSubview(label)
            contentView.addSubview(detailedLabel)
            contentView.addSubview(logoView)

            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .text
            
            detailedLabel.translatesAutoresizingMaskIntoConstraints = false
            detailedLabel.textColor = .text
            
            logoView.translatesAutoresizingMaskIntoConstraints = false
            logoView.contentMode = .scaleAspectFit
            logoView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: .imageLabelSpacing),
                label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                
                detailedLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
                detailedLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                detailedLabel.leadingAnchor.constraint(equalTo: label.leadingAnchor),
                detailedLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                
                logoView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                logoView.topAnchor.constraint(equalTo: label.topAnchor),
                logoView.bottomAnchor.constraint(equalTo: detailedLabel.bottomAnchor),
                logoView.widthAnchor.constraint(equalToConstant: .logoWidth),
                
            ])
         }
         
         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    }
}

extension Input.Table.DetailedTextLogoCell {
    func configure(with model: Input.Field.Header) {
        let image: UIImage?
        if let imageData = model.logoData {
            image = UIImage(data: imageData)
        } else {
            image = nil
        }
        
        logoView.image = image
        label.text = model.label
        detailedLabel.text = model.detailedLabel
    }
}
