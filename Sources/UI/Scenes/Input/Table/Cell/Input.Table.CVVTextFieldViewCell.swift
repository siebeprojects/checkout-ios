// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import MaterialComponents.MaterialTextFields

protocol CVVTextFieldViewCellDelegate: class {
    func presentHint(viewController: UIViewController)
}

extension Input.Table {
    class CVVTextFieldViewCell: TextFieldViewCell, UIAdaptivePresentationControllerDelegate {
        weak var cvvDelegate: CVVTextFieldViewCellDelegate?

        override init(frame: CGRect) {
            super.init(frame: frame)

            let button = UIButton()
            button.setImage(AssetProvider.iconCVVQuestionMark, for: .normal)
            button.addTarget(self, action: #selector(hintButtonDidTap(button:)), for: .touchUpInside)

            textField.rightView = button
            textField.rightViewMode = .always
        }

        @objc private func hintButtonDidTap(button: UIButton) {
            let tooltipVC = TooltipViewController()

            // Configure view controller
            tooltipVC.detailLabelText = model.translator.translation(forKey: "account.verificationCode.hint.where.text")
            tooltipVC.titleLabelText = model.translator.translation(forKey: "account.verificationCode.hint.where.title")

            if let cvvModel = model as? Input.Field.VerificationCode {
                tooltipVC.image = cvvModel.hintImage
            } else {
                tooltipVC.image = AssetProvider.cvvCard
            }

            // Presentation
            tooltipVC.modalPresentationStyle = .popover

            if let presentationController = tooltipVC.presentationController {
                presentationController.delegate = self
            }

            if let popoverController = tooltipVC.popoverPresentationController {
                popoverController.sourceView = button
                popoverController.sourceRect = button.bounds
                popoverController.permittedArrowDirections = [.up, .down, .right]
            }

            cvvDelegate?.presentHint(viewController: tooltipVC)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension Input.Field.VerificationCode {
    var hintImage: UIImage? {
        return networkCode == "AMEX" ? AssetProvider.cvvAMEX : AssetProvider.cvvCard
    }
}

extension Input.Table.CVVTextFieldViewCell: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        .none
    }
}
