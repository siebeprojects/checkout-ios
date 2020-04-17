import UIKit

protocol SupportsPrimaryAction {
    func setPrimaryAction(to action: PrimaryAction)
}

enum PrimaryAction {
    case next, done
}
