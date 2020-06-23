import UIKit

/// Model that contains loadable logo
protocol LoadableLogo: class {
    var logo: Loadable<UIImage>? { get set }
}
