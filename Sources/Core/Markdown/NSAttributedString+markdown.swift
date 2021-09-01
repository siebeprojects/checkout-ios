// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

extension NSAttributedString {
    /// Init attributed string from markdown.
    /// - Warning: only links are supported
    convenience init(markdown: String) {
        let parser = MarkdownParser()
        let attributedString = parser.parse(markdown)
        self.init(attributedString: attributedString)
    }
}
