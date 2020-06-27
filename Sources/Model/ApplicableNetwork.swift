import Foundation

public class ApplicableNetwork: NSObject, Decodable {
    /// Payment network code.
    public let code: String

    /// Display label of the payment network.
    public let label: String

    /// Indicates payment method this network belongs to.
    public let method: String

    /// Grouping code; helps to group several payment networks together while displaying them on payment page (e.g. credit cards).
    public let grouping: String

    /// Indicates whether this payment network supports registration and how this should be presented on payment page
    public let registration: String

    /// Indicates whether this payment network supports recurring registration and how this should be presented on payment page
    public let recurrence: String

    /// If `true` the payment via this network will result in redirect to the PSP web-site (e.g. PayPal, Sofortüberweisung, etc.)
    public let redirect: Bool

    /// Code of button-label when this network is selected.
    public let button: String?

    /// If `true` this network should been initially pre-selected.
    public let selected: Bool?

    /// Map of public available contract data from the first possible route.
    // public let contractData: String?

    /// Data what should been used to dynamically pre-fill a form for this network
    public let formData: FormData?

    /// IFrame height for selective native, only supplied if "iFrame" link is present
    public let iFrameHeight: Int?

    /// Indicates that form for this network is empty, without any text and input elements
    public let emptyForm: Bool?

    ///  Collection of form input elements. This information is only exposed if merchant indicated `jsonForms` option in the `view` query parameter.
    public let localizedInputElements: [InputElement]?

    /// Collection of links related to this payment network in scope of the `LIST` session
    public let links: [String: URL]?

    internal init(code: String, label: String, method: String, grouping: String, registration: String, recurrence: String, redirect: Bool, button: String? = nil, selected: Bool? = nil, formData: FormData? = nil, iFrameHeight: Int? = nil, emptyForm: Bool? = nil, localizedInputElements: [InputElement]?, links: [String: URL]? = nil) {
        self.code = code
        self.label = label
        self.method = method
        self.grouping = grouping
        self.registration = registration
        self.recurrence = recurrence
        self.redirect = redirect
        self.button = button
        self.selected = selected
        self.formData = formData
        self.iFrameHeight = iFrameHeight
        self.emptyForm = emptyForm
        self.localizedInputElements = localizedInputElements
        self.links = links
    }

    // MARK: -

    public enum Requirement: String {
        case NONE, OPTIONAL, OPTIONAL_PRESELECTED, FORCED, FORCED_DISPLAYED
    }

    public var registrationRequirement: Requirement? { Requirement(rawValue: registration) }
    public var recurrenceRequirement: Requirement? {
        Requirement(rawValue: recurrence)
    }
    
    
    /// Current list of payment methods, could be used to initialize enum from `method`. That list could be changed in future or `method` could contain the new value that are not present in enum.
    public enum PaymentMethod: String {
        case BANK_TRANSFER, BILLING_PROVIDER, CASH_ON_DELIVERY, CHECK_PAYMENT, CREDIT_CARD, DEBIT_CARD, DIRECT_DEBIT, ELECTRONIC_INVOICE, GIFT_CARD, MOBILE_PAYMENT, ONLINE_BANK_TRANSFER, OPEN_INVOICE, PREPAID_CARD, TERMINAL, WALLET
    }
}
