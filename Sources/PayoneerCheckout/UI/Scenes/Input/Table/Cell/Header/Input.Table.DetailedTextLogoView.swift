// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

extension Input.Table {
    class DetailedTextLogoView: UICollectionViewCell, Dequeueable {
        let logoView: UIImageView = {
            let imageView = UIImageView()
            imageView.tintColor = .themedDetailedText
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        let primaryLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredThemeFont(forTextStyle: .body)
            label.lineBreakMode = .byTruncatingMiddle
            label.textColor = .themedText
            return label
        }()

        let secondaryLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredThemeFont(forTextStyle: .footnote)
            label.textColor = .themedDetailedText
            return label
        }()

        lazy var trailingButton: UIButton = {
            let button = UIButton(type: .system)
            button.isHidden = true
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            return button
        }()

        var translator: TranslationProvider?
        weak var modalPresenter: ModalPresenter?

        override init(frame: CGRect) {
            super.init(frame: frame)

            directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: .defaultSpacing * 2, vertical: .verticalSpacing)

            logoView.addWidthConstraint(.imageWidth)
            trailingButton.setContentHuggingPriority(.required, for: .horizontal)

            let labelsStackView = UIStackView(arrangedSubviews: [primaryLabel, secondaryLabel])
            labelsStackView.axis = .vertical
            labelsStackView.spacing = .verticalSpacing

            let stackView = UIStackView(arrangedSubviews: [logoView, labelsStackView, trailingButton])
            stackView.alignment = .center
            stackView.spacing = .defaultSpacing * 2
            stackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stackView)
            stackView.fitToSuperview(obeyMargins: true)
         }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    }
}

// MARK: - Interaction

extension Input.Table.DetailedTextLogoView {
    @objc private func buttonAction(_ sender: UIButton) {
        let alert = UIAlertController(
            title: translator?.translation(forKey: "accounts.expired.badge.title"),
            message: translator?.translation(forKey: "accounts.expired.badge.text"),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: translator?.translation(forKey: "button.ok.label"),
                style: .cancel
            )
        )

        modalPresenter?.present(alert, animated: true, completion: nil)
    }
}

extension Input.Table.DetailedTextLogoView {
    func configure(with model: Input.TextHeader) {
        logoView.image = model.logo
        primaryLabel.text = model.label
        secondaryLabel.text = model.detailedLabel
        translator = model.translator
        modalPresenter = model.modalPresenter
    }
}

// MARK: - Constants

private extension CGFloat {
    static var imageWidth: CGFloat { return 50 }
    static var defaultSpacing: CGFloat { return 8 }
    static var verticalSpacing: CGFloat { return 4 }
}
