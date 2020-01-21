import Foundation

/// Provides raw strings.
///
/// We can't use non-swift files (like `.strings`) in Swift Package Manager, that's why we store it as static variables in that class's extensions to make it look similar to Android SDK.
struct RawProvider {
    private init() {}
}
