// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Foundation

class UserAgentBuilder {
    init() {}

    /// Create a version string that should be used as user-agent header's value
    /// Output format: `IOSSDK/<SDK versionNumber> IOSApp/<App versionNumber> (App identifier; App name; App buildNumber) IOSPlatform/<major.minor.patch OS version> (Device model)`
    func createUserAgentValue() -> String {
        var outputSlices = [String]()

        if let frameworkVersion = self.frameworkVersion {
            outputSlices.append(frameworkVersion)
        }

        if let applicationVersion = applicationVersion {
            outputSlices.append(applicationVersion)
        }

        outputSlices.append(platformVersion)

        let outputString = outputSlices.joined(separator: " ")
        return outputString
    }

    /// Returns platform version.
    /// Example: `IOSPlatform/14.2.0 (iPhone)`
    private var platformVersion: String {
        let prefix = "IOSPlatform"

        let version = UIDevice.current.systemVersion
        let model = UIDevice.current.model

        return prefix + "/" + version + " (" + model + ")"
    }

    /// Returns application version string.
    /// Example output: `IOSApp/3.2.1 (bundle.id; Example SDK; 50)`
    private var applicationVersion: String? {
        guard let applicationInfoDictionary = Bundle.main.infoDictionary else { return nil }

        let prefix = "IOSApp"

        guard let applicationVersion = applicationInfoDictionary["CFBundleShortVersionString"] as? String else {
            // Don't return application version if we can't get a version number
            return nil
        }

        // Detailed information in brackets
        let identifier = applicationInfoDictionary["CFBundleIdentifier"] as? String ?? ""
        let displayName = applicationInfoDictionary["CFBundleDisplayName"] as? String ?? ""
        let buildNumber = applicationInfoDictionary["CFBundleVersion"] as? String ?? ""

        // Combine data to output string
        var outputValue = prefix + "/" + applicationVersion

        let filledInformationBlocks = [identifier, displayName, buildNumber].filter { !$0.isEmpty }

        // If we have any detailed information
        if filledInformationBlocks.count != 0 {
            outputValue += " (\(identifier); \(displayName); \(buildNumber))"
        }

        return outputValue
    }

    /// Returns framework version, e.g.: `IOSSDK/1.2.3`
    private var frameworkVersion: String? {
        let frameworkName = "IOSSDK"

        guard let version = getVersionNumber() else { return nil }

        let output = frameworkName + "/" + version
        return output
    }

    /// Get version number specified in `Resources/version.json` file. Returns `nil` if version couldn't be obtained.
    private func getVersionNumber() -> String? {
        guard
            let url = Bundle.module.url(forResource: "version", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let versionContainer = try? JSONDecoder().decode(VersionContainer.self, from: data)
        else {
            return nil
        }

        return versionContainer.version
    }
}

/// Scheme for `version.json` file.
private struct VersionContainer: Decodable {
    let version: String
}
