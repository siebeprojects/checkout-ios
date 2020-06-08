import Foundation

public class AccountRegistration: NSObject, Decodable {
    /// Collection of links to build the account form for this registered account and perform different actions with entered data.
    public let links: [String: URL]

    /// Payment network code of the registration.
    public let code: String

    /// Display label of the payment network for this registration.
    public let label: String
    
    /// Indicates payment method this registered account network belongs to.
    public let method: String?
    
    /// Code of button-label when this registered account is selected.
    public let button: String?

    /// Masked account data of this payment operation or involved account. Sensitive fields of the account are removed, truncated, or replaced with mask characters.
    public let maskedAccount: AccountMask

    /// Timestamp when this account was successfully used last time for payment request.
    public let lastSuccessfulChargeAt: Date?
    
    /// Indicates that this account registration is initially selected.
    public let selected: Bool?
    
    /// IFrame height for selective native, only supplied if "iFrame" link is present.
    public let iFrameHeight: Int?
    
    /// Timestamp when this account was marked as preferred.
    public let preferredAt: Date?
    
    /// Timestamp when this account was created.
    public let createdAt: Date?
    
    /// Indicates that form for this account is empty, without any text and input elements.
    public let emptyForm: Bool?

    /// Collection of form input elements. This information is only exposed if merchant indicated `jsonForms` option in the `view` query parameter.
    public let localizedInputElements: [InputElement]?

    // FIXME: `contractData` is not present
}
