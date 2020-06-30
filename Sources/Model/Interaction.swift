import Foundation

@objc public class Interaction: NSObject, Decodable {
    /// Interaction code that advices further interaction with this customer or payment.
    /// See list of [Interaction Codes](https://www.optile.io/opg#292619).
    public let code: String

    /// Reason of this interaction, complements interaction code and has more detailed granularity.
    /// See list of [Interaction Codes](https://www.optile.io/opg#292619).
    public let reason: String
}

internal extension Interaction {
    enum Code: String, Decodable, SnakeCaseRepresentable, CaseIterable {
        case proceed
        case abort
        case tryOtherNetwork
        case tryOtherAccount
        case retry
        case reload
        case verify
    }

    enum Reason: String, Decodable, SnakeCaseRepresentable, CaseIterable {
        case ok
        case pending
        case trusted
        case strongAuthentication
        case declined
        case expired
        case exceedsLimit
        case temporaryFailure
        case unknown
        case networkFailure
        case blacklisted
        case blocked
        case systemFailure
        case invalidAccCOMMUNICATION_FAILUREount
        case fraud
        case additionalNetworks
        case invalidRequest
        case scheduled
        case noNetworks
        case duplicateOperation
        case chargeback
        case riskDetected
        case customerAbort
        case expiredSession
        case expiredAccount
        case accountNotActivated
        case trustedCustomer
        case unknownCustomer
        case activated
        case updated
        case takeAction
        
        case communicationFailure
        case clientsideError
    }
}
