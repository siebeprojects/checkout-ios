import UIKit

@objc public class Theme: NSObject {
    public var font: UIFont
    
    internal var backgroundColor: UIColor
    
    public var textColor: UIColor
    public var subtitleTextColor: UIColor
    public var detailTextColor: UIColor
    public var buttonTextColor: UIColor
    
    public var tintColor: UIColor
    public var navigationBarBackgroundColor: UIColor
    public var errorTextColor: UIColor
    
    public init(font: UIFont, backgroundColor: UIColor, textColor: UIColor, subtitleTextColor: UIColor, detailTextColor: UIColor, buttonTextColor: UIColor, tintColor: UIColor, navigationBarBackgroundColor: UIColor, errorTextColor: UIColor) {
        self.font = font
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.subtitleTextColor = subtitleTextColor
        self.detailTextColor = detailTextColor
        self.buttonTextColor = buttonTextColor
        self.tintColor = tintColor
        self.navigationBarBackgroundColor = navigationBarBackgroundColor
        self.errorTextColor = errorTextColor
    }
}

public extension Theme {
    static var shared: Theme = .standart
    
    static var standart: Theme {
        let textColor = UIColor(white: 66.0 / 255.0, alpha: 1.0)
        let detailedTextColor = UIColor(white: 143.0 / 255.0, alpha: 1.0)
        let tintColor = UIColor(red: 0.0, green: 137.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
        
        let backgroundColor: UIColor
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        return Theme(font: UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize),
              backgroundColor: backgroundColor,
              textColor: textColor,
              subtitleTextColor: textColor,
              detailTextColor: detailedTextColor,
              buttonTextColor: textColor,
              tintColor: tintColor,
              navigationBarBackgroundColor: textColor,
              errorTextColor: textColor)
    }
}

internal extension UIColor {
    static var themedText: UIColor {
        return Theme.shared.textColor
    }
    
    static var themedDetailedText: UIColor {
        return Theme.shared.detailTextColor
    }
    
    static var themedTint: UIColor {
        return Theme.shared.tintColor
    }
    
    static var themedBackground: UIColor {
        return Theme.shared.backgroundColor
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
