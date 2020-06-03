import UIKit

private extension UIColor {
    static var titleColor: UIColor { .white }
}

private extension CGFloat {
    static var cornerRadius: CGFloat { return 4 }
    static var buttonHeight: CGFloat { 44 }
}

extension Input.Table {
    class ButtonCell: FullWidthCollectionViewCell, DequeueableCell {
        private let button: UIButton
        var model: Input.Field.Button?

        override init(frame: CGRect) {
            button = .init(frame: .zero)
            button.setTitleColor(.titleColor, for: .normal)
            button.layer.cornerRadius = .cornerRadius
            button.clipsToBounds = true

            super.init(frame: frame)

            contentView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false
            
            let buttonBottomConstraint = button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            buttonBottomConstraint.priority = .defaultHigh
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: contentView.topAnchor),
                buttonBottomConstraint,
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                button.heightAnchor.constraint(equalToConstant: .buttonHeight)
            ])

            button.addTarget(self, action: #selector(buttonDidTap), for: .primaryActionTriggered)
         }

        @objc private func buttonDidTap() {
            guard let model = self.model else { return }
            model.buttonDidTap?(model)
        }

         required init?(coder: NSCoder) {
             fatalError("init(coder:) has not been implemented")
         }
    }
}

extension Input.Table.ButtonCell {
    func configure(with model: Input.Field.Button) {
        self.model = model

        button.backgroundColor = button.tintColor

        let attributedString = NSAttributedString(
            string: model.label,
            attributes: [
                .font: UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .semibold),
                .foregroundColor: UIColor.titleColor
            ]
        )

        button.setAttributedTitle(attributedString, for: .normal)
    }
}
