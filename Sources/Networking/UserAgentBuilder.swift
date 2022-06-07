// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import UIKit
import Foundation
import Logging

class UserAgentBuilder: Loggable {
    init() {}

    /// Create a version string that should be used as user-agent header's value
    /// Output format: `IOSSDK/<SDK versionNumber> IOSApp/<App versionNumber> (App identifier; App name; App buildNumber) IOSPlatform/<major.minor.patch OS version> (Device model)`
    func createUserAgentValue() -> String {
        var outputSlices = [String]()

        do {
            try outputSlices.append(getFrameworkVersion())
            try outputSlices.append(getApplicationVersion())
        } catch {
            if #available(iOS 14.0, *) {
                error.log(to: logger, level: .info)
            }
        }

        outputSlices.append(getPlatformVersion())

        let outputString = outputSlices.joined(separator: " ")
        return outputString
    }

    /// Returns platform version.
    /// Example: `IOSPlatform/14.2.0 (iPhone)`
    private func getPlatformVersion() -> String {
        let prefix = "IOSPlatform"

        let version = UIDevice.current.systemVersion
        let model = UIDevice.current.model

        return prefix + "/" + version + " (" + model + ")"
    }

    /// Returns application version string.
    /// Example output: `IOSApp/3.2.1 (bundle.id; Example SDK; 50)`
    private func getApplicationVersion() throws -> String {
        guard let applicationInfoDictionary = Bundle.main.infoDictionary else {
            throw NetworkingError(description: "Unable to read application's Info.plist")
        }

        let prefix = "IOSApp"

        guard let applicationVersion = applicationInfoDictionary["CFBundleShortVersionString"] as? String else {
            // Don't return application version if we can't get a version number
            throw NetworkingError(description: "Couldn't obtain application's version number (CFBundleShortVersionString)")
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
    private func getFrameworkVersion() throws -> String {
        let frameworkName = "IOSSDK"
        let version = try getVersionNumber()
        let output = frameworkName + "/" + version
        return output
    }

    /// Get version number specified in `Resources/version.json` file. Returns `nil` if version couldn't be obtained.
    private func getVersionNumber() throws -> String {
        guard let url = Bundle.module.url(forResource: "version", withExtension: "json") else {
            throw NetworkingError(description: "Unable to build url for version.json")
        }

        let data = try Data(contentsOf: url)
        let versionContainer = try JSONDecoder().decode(VersionContainer.self, from: data)

        return versionContainer.version
    }
}

/// Scheme for `version.json` file.
private struct VersionContainer: Decodable {
    let version: String
}
