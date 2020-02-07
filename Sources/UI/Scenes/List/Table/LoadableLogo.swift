import Foundation

/// Model that contains loadable logo
protocol LoadableLogo: class {
    var logo: Loadable<Data>? { get set }
}
