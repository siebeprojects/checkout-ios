// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// A set of functions that you use to manage the editing of text in a TextInputView.
protocol TextInputViewDelegate: AnyObject {
    func textInputViewDidBeginEditing(_ view: TextInputView)
    func textInputView(_ view: TextInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textInputViewDidTapTrailingButton(_ view: TextInputView)
    func textInputViewShouldReturn(_ view: TextInputView) -> Bool
    func textInputViewDidEndEditing(_ view: TextInputView)
}

// Optional methods
extension TextInputViewDelegate {
    func textInputViewDidBeginEditing(_ view: TextInputView) {}
    func textInputView(_ view: TextInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { true }
    func textInputViewDidTapTrailingButton(_ view: TextInputView) {}
    func textInputViewShouldReturn(_ view: TextInputView) -> Bool { false }
    func textInputViewDidEndEditing(_ view: TextInputView) {}
}
