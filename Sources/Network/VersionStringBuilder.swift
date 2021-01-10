// Copyright (c) 2020 optile GmbH
// https://www.optile.net
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit

class VersionStringBuilder {
    init() {}

    /// Create a version string that should be used as user-agent header's value
    /// Output format: `ios-sdk/<SDK versionNumber> (SDK buildNumber) <App/App versionNumber> (App identifier; App name; App buildNumber) <Platform/major.minor.patch OS version> (Device model; Device name)`
    /// Example output: `ios-sdk/1.2.3 (43) App/3.2.1 (net.optile.example.sdk; Example SDK; 50) Platform/14.2.0 (iPhone; iPhone SE (2nd generation))`
    func createUserAgentValue() -> String {
        var outputSlices = [String]()

        outputSlices.append(frameworkVersion)

        if let applicationVersion = applicationVersion {
            outputSlices.append(applicationVersion)
        }

        outputSlices.append(platformVersion)

        return outputSlices.joined(separator: " ")
    }

    /// Returns platform version.
    /// Example: `Platform/14.2.0 (iPhone; iPhone SE (2nd generation))`
    private var platformVersion: String {
        let prefix = "Platform"

        let version = UIDevice.current.systemVersion
        let name = UIDevice.current.name
        let model = UIDevice.current.model

        return prefix + "/" + version + " (" + model + "; " + name + ")"
    }

    /// Returns application version string.
    /// Example output: `App/3.2.1 (net.optile.example.sdk; Example SDK; 50)`
    private var applicationVersion: String? {
        guard let applicationInfoDictionary = Bundle.main.infoDictionary else { return nil }

        let prefix = "App"

        let applicationVersion = applicationInfoDictionary["CFBundleShortVersionString"] as? String

        // Detailed information in brackets
        var detailedInformation = [String]()

        if let identifier = applicationInfoDictionary["CFBundleIdentifier"] as? String {
            detailedInformation.append(identifier)
        }

        if let displayName = applicationInfoDictionary["CFBundleDisplayName"] as? String {
            detailedInformation.append(displayName)
        }

        if let buildNumber = applicationInfoDictionary["CFBundleVersion"] as? String {
            detailedInformation.append(buildNumber)
        }

        // Combine data to output string
        var outputValue = String()
        if let version = applicationVersion {
            outputValue = prefix + "/" + version
        } else {
            outputValue = prefix
        }

        if !detailedInformation.isEmpty {
            outputValue += " (" + detailedInformation.joined(separator: "; ") + ")"
        }

        return outputValue
    }

    /// Returns framework version, e.g.: 1.2.3 (43).
    private var frameworkVersion: String {
        let frameworkName = "ios-sdk"

        let infoDictionary = Bundle(for: VersionStringBuilder.self).infoDictionary
        if let version = infoDictionary?["CFBundleShortVersionString"] as? String, let build = infoDictionary?["CFBundleVersion"] as? String {
            return frameworkName + "/" + version + " (" + build + ")"
        } else {
            return frameworkName
        }
    }
}
