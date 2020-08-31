import UIKit

@objc public class Theme: NSObject {
    public var font: UIFont

    public var backgroundColor: UIColor
    public var tableBorder: UIColor
    public var tableCellSeparator: UIColor

    public var textColor: UIColor
    public var detailTextColor: UIColor
    public var buttonTextColor: UIColor

    public var tintColor: UIColor
    public var errorTextColor: UIColor

    public init(font: UIFont, backgroundColor: UIColor, tableBorder: UIColor, tableCellSeparator: UIColor, textColor: UIColor, detailTextColor: UIColor, buttonTextColor: UIColor, tintColor: UIColor, errorTextColor: UIColor) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.tableBorder = tableBorder
        self.tableCellSeparator = tableCellSeparator
        self.textColor = textColor
        self.detailTextColor = detailTextColor
        self.buttonTextColor = buttonTextColor
        self.tintColor = tintColor
        self.errorTextColor = errorTextColor
    }
}

public extension Theme {
    static var shared: Theme = .standart

    static var standart: Theme {
        let textColor = UIColor(white: 66.0 / 255.0, alpha: 1.0)
        let detailedTextColor = UIColor(white: 143.0 / 255.0, alpha: 1.0)
        let tintColor = UIColor(red: 0.0, green: 137.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
        let border = UIColor(white: 224.0 / 255.0, alpha: 1.0)
        let separator = UIColor(white: 242.0 / 255.0, alpha: 1.0)

        let backgroundColor: UIColor
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }

        return Theme(
            font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
            backgroundColor: backgroundColor,
            tableBorder: border,
            tableCellSeparator: separator,
            textColor: textColor,
            detailTextColor: detailedTextColor,
            buttonTextColor: .white,
            tintColor: tintColor,
            errorTextColor: textColor
        )
    }
}

internal extension UIColor {
    static var themedText: UIColor {
        return Theme.shared.textColor
    }

    static var themedDetailedText: UIColor {
        return Theme.shared.detailTextColor
    }

    static var themedButtonTextColor: UIColor {
        return Theme.shared.buttonTextColor
    }

    static var themedTint: UIColor {
        return Theme.shared.tintColor
    }

    static var themedBackground: UIColor {
        return Theme.shared.backgroundColor
    }

    static var themedTableBorder: UIColor {
        return Theme.shared.tableBorder
    }

    static var themedTableCellSeparator: UIColor {
        return Theme.shared.tableCellSeparator
    }

    static var themedError: UIColor {
        return Theme.shared.errorTextColor
    }
}

internal extension UIFont {
    static var theme: UIFont {
        return Theme.standart.font
    }

    func withSize(forTextStyle textStyle: TextStyle) -> UIFont {
        let size = UIFont.preferredFont(forTextStyle: textStyle).pointSize
        return self.withSize(size)
    }
}
