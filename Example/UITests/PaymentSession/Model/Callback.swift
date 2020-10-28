import Foundation

/// Callback information about merchants shop system. It is strongly advised to provide this data with every transaction.
struct Callback: Codable {
    /// URL of landing page in merchants shop system for successful payment. Customer will be redirected to this URL after successful payment.
    var returnUrl: String

    /// URL of landing page in merchants shop system after customer select payment method. This property is mandatory for a `LIST` session with `operationType` of `PRESET`, or with deprecated `presetFirst` option set to `true`.
    var summaryUrl: String?

    /// URL of landing page in merchants shop system for cancelled or failed payment. Customer will be redirected to this URL after canceled or permanently failed payment.
    var cancelUrl: String

    /// Payment status notification URL. If defined, the OPG system will send asynchronous status notifications about this payment to this URL.
    ///
    /// - Note: merchant can configure a single notification URL for all transactions on the _division_ level via Merchant Configuration API. Notification URL in `callback`, however, overrides the division settings.
    var notificationUrl: String?
}
