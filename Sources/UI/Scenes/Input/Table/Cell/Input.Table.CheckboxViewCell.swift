#if canImport(UIKit)
import UIKit

private struct UIConstant {
    static let defaultSpacing: CGFloat = 8
}

extension Input.Table {
    /// Cell that represents a checkbox (UISwitch).
    /// Upon some actions calls `delegate`, don't forget to set it.
    ///
    /// - Warning: after initialization before using you have to set `indexPath` to cell's indexPath
    class CheckboxViewCell: FullWidthCollectionViewCell, DequeueableCell {
        weak var delegate: InputCellDelegate?

        private let label: UILabel
        let checkbox: UISwitch

        override init(frame: CGRect) {
            label = .init(frame: .zero)
            checkbox = .init(frame: .zero)

            super.init(frame: frame)

            // Configure label
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.textColor = .text
            label.font = UIFont.preferredFont(forTextStyle: .body)

            // Configure checkbox
            checkbox.addTarget(self, action: #selector(checkboxValueChanged), for: .valueChanged)

            // Layout
            contentView.addSubview(label)
            contentView.addSubview(checkbox)

            label.translatesAutoresizingMaskIntoConstraints = false
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let bottomLabelConstraint = label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            bottomLabelConstraint.priority = .defaultHigh
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: checkbox.leadingAnchor, constant: -UIConstant.defaultSpacing),
                bottomLabelConstraint,
                label.topAnchor.constraint(equalTo: contentView.topAnchor),

                checkbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }

        @objc private func checkboxValueChanged(_ sender: UISwitch) {
            delegate?.inputCellValueDidChange(to: checkbox.isOn.stringValue, cell: self)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - Cell configuration

extension Input.Table.CheckboxViewCell {
    func configure(with model: Input.Field.Checkbox) {
        label.text = model.name
        checkbox.isOn = model.isOn
        checkbox.isHidden = model.isHidden
        checkbox.isEnabled = model.isEnabled
        checkbox.onTintColor = self.tintColor
    }
}

extension Input.Table.CheckboxViewCell: ContainsInputCellDelegate {}
#endif
