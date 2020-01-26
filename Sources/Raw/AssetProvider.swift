import Foundation

#if canImport(UIKit)
import UIKit
#endif

final class AssetProvider {
    private static var bundle: Bundle {
        .init(for: AssetProvider.self)
    }
    
    #if canImport(UIKit)
    static var iconCard: UIImage? {
        let image = UIImage(named: "iconCard", in: bundle, compatibleWith: nil)
        return image
    }
    #endif
    
    static func getGroupingRulesData() throws -> Data {
        guard let url = bundle.url(forResource: "groups", withExtension: "json") else {
            throw InternalError(description: "Unable to build a path for groups.json")
        }
        
        return try Data(contentsOf: url)
    }
    
    static func getValidationsData() throws -> Data {
        guard let url = bundle.url(forResource: "validations", withExtension: "json") else {
            throw InternalError(description: "Unable to build a path for validations.json")
        }
        
        return try Data(contentsOf: url)
    }
}
