// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// A set of functions that you use to manage the editing of text in a TextInputView.
protocol TextInputViewDelegate: AnyObject {
    /// Tells the delegate when editing begins.
    func textInputViewDidBeginEditing(_ view: TextInputView)

    /// Asks the delegate whether to change the specified text.
    /// - Returns: `true` if the specified text range should be replaced; otherwise, `false` to keep the old text.
    func textInputView(_ view: TextInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool

    /// Tells the delegate when the trailing button is tapped.
    func textInputViewDidTapTrailingButton(_ view: TextInputView)

    /// Asks the delegate whether to process the pressing of the Return button.
    /// - Returns: `true` if the text field should implement its default behavior for the return button; otherwise, `false`.
    func textInputViewShouldReturn(_ view: TextInputView) -> Bool

    /// Tells the delegate when editing stops.
    func textInputViewDidEndEditing(_ view: TextInputView)
}

/// Optional methods
extension TextInputViewDelegate {
    func textInputViewDidBeginEditing(_ view: TextInputView) {}
    func textInputView(_ view: TextInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { true }
    func textInputViewDidTapTrailingButton(_ view: TextInputView) {}
    func textInputViewShouldReturn(_ view: TextInputView) -> Bool { false }
    func textInputViewDidEndEditing(_ view: TextInputView) {}
}
