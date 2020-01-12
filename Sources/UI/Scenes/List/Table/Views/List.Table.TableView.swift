#if canImport(UIKit)
import UIKit

extension List.Table {
    final class TableView: UITableView {
        override var contentSize:CGSize {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }

        override var intrinsicContentSize: CGSize {
            layoutIfNeeded()
            
            return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
        }
    }
}
#endif
