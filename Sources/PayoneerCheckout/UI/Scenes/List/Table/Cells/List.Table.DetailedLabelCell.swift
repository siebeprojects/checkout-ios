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
            let label = UILabel()
            label.font = UIFont.preferredThemeFont(forTextStyle: .body)
            label.textColor = .themedText
            return label
        }()

        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredThemeFont(forTextStyle: .footnote)
            label.textColor = .themedDetailedText
            return label
        }()

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
    func configure(logo: UIImage?, title: String, subtitle: String?) {
        logoImageView.image = logo
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil || subtitle?.isEmpty == true
    }
}

// MARK: - Layout

extension List.Table.DetailedLabelCell {
    private func layout() {
        customContentView.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: .defaultSpacing * 2, vertical: .verticalSpacing)

        logoImageView.addWidthConstraint(.imageWidth)

        let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = .verticalSpacing

        let stackView = UIStackView(arrangedSubviews: [logoImageView, labelsStackView])
        stackView.alignment = .center
        stackView.spacing = .defaultSpacing * 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        customContentView.addSubview(stackView)
        stackView.fitToSuperview(obeyMargins: true)
    }
}

// MARK: - Constants

private extension CGFloat {
    static var imageWidth: CGFloat { return 50 }
    static var defaultSpacing: CGFloat { return 8 }
    static var verticalSpacing: CGFloat { return 4 }
}
#endif
