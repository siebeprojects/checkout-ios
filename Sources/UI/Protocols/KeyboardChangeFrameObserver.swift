#if canImport(UIKit)
import UIKit

/// Observer that will fire events when keyboard frame will be changed (shown, hidden or resized)
/// - Note: Call `addKeyboardFrameChangesObserver()` on init, e.g. on `viewWillAppear`
///            and `removeKeyboardFrameChangesObserver()` on deinit, e.g. on `viewDidDisappear`
public protocol KeyboardFrameChangesObserver: class {
    func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIView.AnimationOptions)
}

public extension KeyboardFrameChangesObserver {
    func addKeyboardFrameChangesObserver() {
        let center = NotificationCenter.default

        center.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.sendDelegate(notification: notification, willHide: false)
        }

        center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.sendDelegate(notification: notification, willHide: true)
        }
    }

    func removeKeyboardFrameChangesObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func sendDelegate(notification: Notification, willHide: Bool) {
        guard let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let rawAnimationCurveNumber = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }

        let rawAnimationCurve = rawAnimationCurveNumber.uint32Value << 16
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(rawAnimationCurve))

        let keyboardHeight = willHide ? 0 : keyboardEndFrame.height

        willChangeKeyboardFrame(height: keyboardHeight,
                                animationDuration: animationDuration,
                                animationOptions: [.beginFromCurrentState, animationCurve])
    }
}

/// Insets of a scroll view will be changed when keyboard will appear
protocol ModifableInsetsOnKeyboardFrameChanges: KeyboardFrameChangesObserver {
    /// Insets of that scroll view will be modified on keyboard appearance
    var scrollViewToModify: UIScrollView? { get }
}

/// Default implementation for `UIViewController`
extension ModifableInsetsOnKeyboardFrameChanges where Self: UIViewController {
    func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIView.AnimationOptions) {
        guard let scrollViewToModify = scrollViewToModify else { return }

        var adjustedHeight = height

        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            adjustedHeight -= tabBarHeight
        } else if let toolbarHeight = navigationController?.toolbar.frame.height, navigationController?.isToolbarHidden == false {
            adjustedHeight -= toolbarHeight
        }

        if #available(iOS 11.0, *) {
            adjustedHeight -= view.safeAreaInsets.bottom
        }

        if adjustedHeight < 0 { adjustedHeight = 0 }

        UIView.animate(withDuration: animationDuration, animations: {
            let newInsets = UIEdgeInsets(top: 0, left: 0, bottom: adjustedHeight, right: 0)
            scrollViewToModify.contentInset = newInsets
            scrollViewToModify.scrollIndicatorInsets = newInsets
        })
    }
}
#endif
