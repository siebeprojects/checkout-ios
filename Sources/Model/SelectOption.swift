import Foundation

public class SelectOption: NSObject, Decodable {
    /// The value for this option.
    public let value: String

    /// If set to `true` this option should be pre-selected, otherwise no specific behavior should be applied for this option.
    public let selected: Bool?
}
