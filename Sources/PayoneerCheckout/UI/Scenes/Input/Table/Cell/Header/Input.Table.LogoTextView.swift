// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import UIKit

private extension CGFloat {
    static let logoWidth: CGFloat = 52
    static let imageLabelSpacing: CGFloat = 16
}

extension Input.Table {
    class LogoTextView: UICollectionViewCell, Dequeueable {
        private let titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.preferredThemeFont(forTextStyle: .body)
            titleLabel.textColor = .themedText
            titleLabel.lineBreakMode = .byTruncatingMiddle
            return titleLabel
        }()

        private let logoImageView = UIImageView()

        override init(frame: CGRect) {
            super.init(frame: frame)

            logoImageView.addWidthConstraint(.logoWidth)

            let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
            stackView.alignment = .center
            stackView.spacing = .imageLabelSpacing
            stackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stackView)
            stackView.fitToSuperview(obeyMargins: false)
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    }
}

extension Input.Table.LogoTextView {
    func configure(with model: Input.TextHeader) {
        logoImageView.image = model.logo
        titleLabel.text = model.title
    }
}
#endif
