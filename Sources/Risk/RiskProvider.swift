// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

import Foundation

/// A protocol which all risk providers must conform to.
public protocol RiskProvider {
    static var code: String { get }
    static var type: String? { get }

    /// Loads a risk provider.
    /// That method doesn't guarantee to initialize the new risk provider for each call, previously initialized risk provider could be returned with an updated configuration.
    /// - Parameters:
    ///   * parameters: Information required to initialize the risk provider.
    /// - Returns: An instance of the risk provider.
    static func load(withParameters parameters: [String: String?]) throws -> Self

    /// Collects the relevant data for a risk assessment.
    /// - Returns: A dictionary containing relevant data that will be sent to a server.
    func collectRiskData() throws -> [String: String?]?
}
