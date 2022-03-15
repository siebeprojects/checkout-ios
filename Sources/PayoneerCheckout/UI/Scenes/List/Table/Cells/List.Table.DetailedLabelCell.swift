// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)
import Foundation
import UIKit

extension List.Table {
    /// Cell with multiple images, primary and secondary labels.
    /// - Note: set `cellIndex`
    final class DetailedLabelCell: List.Table.BorderedCell, Dequeueable {
        private let logoImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.tintColor = .themedDetailedText
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        private let titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.preferredThemeFont(forTextStyle: .body)
            titleLabel.lineBreakMode = .byTruncatingMiddle
            titleLabel.textColor = .themedText
            return titleLabel
        }()

        private let subtitleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.preferredThemeFont(forTextStyle: .footnote)
            titleLabel.textColor = .themedText
            return titleLabel
        }()

        private lazy var trailingButton: UIButton = {
            let button = UIButton(type: .system)
            button.isHidden = true
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            return button
        }()

        var translator: TranslationProvider?
        weak var modalPresenter: ModalPresenter?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            layout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Configuration

extension List.Table.DetailedLabelCell {
    func configure(
        logo: UIImage?,
        title: String,
        subtitle: String?,
        subtitleColor: UIColor? = nil,
        trailingButtonImage: UIImage? = nil,
        trailingButtonColor: UIColor? = nil,
        translator: TranslationProvider? = nil,
        modalPresenter: ModalPresenter? = nil
    ) {
        self.logoImageView.image = logo
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.subtitleLabel.isHidden = subtitle == nil || subtitle?.isEmpty == true
        self.subtitleLabel.textColor = subtitleColor ?? .themedText
        self.translator = translator
        self.modalPresenter = modalPresenter
        self.trailingButton.tintColor = trailingButtonColor

        if let buttonImage = trailingButtonImage {
            self.trailingButton.setImage(buttonImage, for: .normal)
            self.trailingButton.isHidden = false
        } else {
            self.trailingButton.setImage(nil, for: .normal)
            self.trailingButton.isHidden = true
        }
    }
}

// MARK: - Layout

extension List.Table.DetailedLabelCell {
    private func layout() {
        customContentView.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: .defaultSpacing * 2, vertical: .verticalSpacing)

        logoImageView.addWidthConstraint(.imageWidth)
        trailingButton.setContentHuggingPriority(.required, for: .horizontal)

        let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = .verticalSpacing

        let stackView = UIStackView(arrangedSubviews: [logoImageView, labelsStackView, trailingButton])
        stackView.alignment = .center
        stackView.spacing = .defaultSpacing * 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.addSubview(stackView)
        stackView.fitToSuperview(obeyMargins: true)
    }
}

// MARK: - Interaction

extension List.Table.DetailedLabelCell {
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

// MARK: - Constants

private extension CGFloat {
    static var imageWidth: CGFloat { return 50 }
    static var defaultSpacing: CGFloat { return 8 }
    static var verticalSpacing: CGFloat { return 4 }
}
#endif
