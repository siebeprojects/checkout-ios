import Foundation

public class Parameter: NSObject, Decodable {
    /// Parameter name.
    public let name: String

    /// Parameter value.
    public let value: String?
    
    internal init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}
