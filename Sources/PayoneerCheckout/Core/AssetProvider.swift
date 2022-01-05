// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

final class AssetProvider {
    #if canImport(UIKit)
    static var iconCard: UIImage? {
        return UIImage(named: "iconCard", in: .current, compatibleWith: nil)
    }

    static var iconCVVQuestionMark: UIImage? {
        return UIImage(named: "iconCVVQuestionMark", in: .current, compatibleWith: nil)
    }

    static var cvvCard: UIImage? {
        return UIImage(named: "cvvCard", in: .current, compatibleWith: nil)
    }

    static var cvvAMEX: UIImage? {
        return UIImage(named: "cvvAMEX", in: .current, compatibleWith: nil)
    }

    static var iconClear: UIImage? {
        return UIImage(named: "iconClear", in: .current, compatibleWith: nil)
    }

    static var expirationInfo: UIImage? {
        return UIImage(named: "expirationInfo", in: .current, compatibleWith: nil)
    }

    static var disclosureIndicator: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "chevron.right")
        } else {
            return UIImage(named: "disclosureIndicator", in: .current, compatibleWith: nil)
        }
    }
    #endif

    static func getGroupingRulesData() throws -> Data {
        guard let url = Bundle.current.url(forResource: "groups", withExtension: "json") else {
            throw InternalError(description: "Unable to build a path for groups.json")
        }

        return try Data(contentsOf: url)
    }

    static func getValidationsData() throws -> Data {
        guard let url = Bundle.current.url(forResource: "validations", withExtension: "json") else {
            throw InternalError(description: "Unable to build a path for validations.json")
        }

        return try Data(contentsOf: url)
    }

    static func getValidationsDefaultData() throws -> Data {
        guard let url = Bundle.current.url(forResource: "validations-default", withExtension: "json") else {
            throw InternalError(description: "Unable to build a path for validations-default.json")
        }

        return try Data(contentsOf: url)
    }
}
