import Foundation

#if canImport(UIKit)
import UIKit
#endif

final class AssetProvider {
    #if canImport(UIKit)
    static var iconCard: UIImage? {
        let bundle = Bundle(for: AssetProvider.self)
        let image = UIImage(named: "iconCard", in: bundle, compatibleWith: nil)
        return image
    }
    #endif
}
