import Foundation

// MARK: - Request

/// Gets active LIST session details
///
/// Retrieves available payment capabilities for active `LIST` session.
/// Response model is `
public struct DownloadLocalization: GetRequest {
    public var url: URL
    let queryItems = [URLQueryItem]()
    public typealias Response = [String: String]

    /// - Parameter url: `self` link from payment session
    public init(from url: URL) {
        self.url = url
    }

    public func decodeResponse(with data: Data?) throws -> Response {
        guard let data = data else {
            throw InternalError(description: "Localization file download error: no data was in a response")
        }

        guard let text = String(data: data, encoding: .isoLatin1) else {
            throw InternalError(description: "Unable to decode localization file: unable to decode a data fro isoLatin1")
        }
        
        let transform = StringTransform(rawValue: "Any-Hex/Java")
        guard let unescapedString = text.applyingTransform(transform, reverse: true) else {
            throw InternalError(description: "Couldn't unescape string: %@", text)
        }

        var localization = [String: String]()
        for line in unescapedString.components(separatedBy: .newlines) {
            let keyValueLine = line.components(separatedBy: "=")
            guard keyValueLine.count == 2 else { continue }
            
            let key = keyValueLine[0].trimmingCharacters(in: .whitespaces)
            let value = keyValueLine[1].trimmingCharacters(in: .whitespaces)
            localization[key] = value
        }

        return localization
    }
}
