import Foundation

extension Input {
    struct ReplaceableString {
        let origin: String
        let changesRange: NSRange
        let replacement: String
        
        func replacing() -> String {
            guard let textRange = Range(changesRange, in: origin) else { return origin }
            return origin.replacingCharacters(in: textRange, with: replacement)
        }
    }
}
