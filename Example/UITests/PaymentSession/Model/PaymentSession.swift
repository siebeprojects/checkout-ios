import Foundation

struct PaymentSession: Decodable {
    let links: Links

    struct Links: Decodable {
        let `self`: URL
    }
}
