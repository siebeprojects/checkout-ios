import Foundation

/// Payment information.
struct Payment: Codable {
    /// Short description of the order given by merchant. This will appear on bank statements or invoices of customer account if supported by PSP and selected payment method.
    var reference: String

    /// The total amount (including taxes, shipping, etc.) of this order in native format using "." as decimal delimiter. Customer will be charged for this amount.
    var amount: Double

    /// Currency of this payment. Value format is according to ISO-4217 form, e.g. "EUR", "USD".
    var currency: String
}
