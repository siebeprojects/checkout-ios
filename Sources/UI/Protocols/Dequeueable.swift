// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#if canImport(UIKit)

import UIKit

protocol Dequeueable: AnyObject {
    static var identifier: String { get }
}

extension Dequeueable where Self: NSObject {
    static var identifier: String {
        return self.nameOfClass
    }
}

extension UITableView {
    func dequeueReusableCell<Cell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: Dequeueable & UITableViewCell {
        // swiftlint:disable:next force_cast
        return self.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
    }

    func register<Cell>(_ cellClass: Cell.Type) where Cell: Dequeueable & UITableViewCell {
        self.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
    }

    func dequeueReusableHeaderFooterView<HeaderFooterView>(_ cellClass: HeaderFooterView.Type) -> HeaderFooterView where HeaderFooterView: Dequeueable & UITableViewHeaderFooterView {
        // swiftlint:disable:next force_cast
        return self.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterView.identifier) as! HeaderFooterView
    }

    func register<HeaderFooterView>(_ viewClass: HeaderFooterView.Type) where HeaderFooterView: Dequeueable & UITableViewHeaderFooterView {
        self.register(HeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterView.identifier)
    }
}

extension UICollectionView {
    func dequeueReusableCell<Cell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: Dequeueable & UICollectionViewCell {
        // swiftlint:disable:next force_cast
        return self.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
    }

    func dequeueReusableCell(_ cellClass: (Dequeueable & UICollectionViewCell).Type, for indexPath: IndexPath) -> UICollectionViewCell {
        return self.dequeueReusableCell(withReuseIdentifier: cellClass.identifier, for: indexPath)
    }

    func dequeueReusableSupplementaryView<Cell>(_ cellClass: Cell.Type, ofKind kind: String, for indexPath: IndexPath) -> Cell where Cell: Dequeueable & UICollectionReusableView {
        // swiftlint:disable:next force_cast
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
    }

    func register<Cell>(_ cellClass: Cell.Type) where Cell: Dequeueable & UICollectionViewCell {
        self.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
    }

    func register<Cell>(_ cellClass: Cell.Type, forSupplementaryViewOfKind kind: String) where Cell: Dequeueable & UICollectionReusableView {
        self.register(Cell.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: Cell.identifier)
    }
}

// MARK: - NSObject extension

private extension NSObject {
    class var nameOfClass: String {
        let fullClassName = NSStringFromClass(self)
        guard let className = fullClassName.components(separatedBy: ".").last else {
            assertionFailure("Using unexpected class name (full)")
            return fullClassName
        }

        return className
    }

    var nameOfClass: String {
        let fullClassName = NSStringFromClass(type(of: self))
        guard let className = fullClassName.components(separatedBy: ".").last else {
            assertionFailure("Using unexpected class name (full)")
            return fullClassName
        }

        return className
    }
}
#endif
