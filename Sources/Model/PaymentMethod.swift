import Foundation

/// Current list of payment methods. That list could be changed in future or `method` could contain the new value that are not present in enum.
enum PaymentMethod: String, SnakeCaseRepresentable {
    case bankTransfer
    case billingProvider
    case cashOnDelivery
    case checkPayment
    case creditCard
    case debitCard
    case directDebit
    case electronicInvoice
    case giftCard
    case mobilePayment
    case onlineBankTransfer
    case openInvoice
    case prepaidCard
    case terminal
    case wallet
}
