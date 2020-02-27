import UIKit

/// Abstract class for view controller that may be presented using slide-in transition
class SlideInViewController: UIViewController {
    weak var scrollView: UIScrollView!

    // MARK: Calculated variables

    private var isPresentedAsForm: Bool {
        return navigationController?.presentationController?.adaptivePresentationStyle(for: traitCollection) == .some(.formSheet)
    }
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.bounces = isPresentedAsForm

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(rightBarButtonDidTap))
        saveButton.style = .done
        navigationItem.setRightBarButton(saveButton, animated: false)
    }

    @objc func rightBarButtonDidTap() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardFrameChangesObserver()
    }

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        setPreferredContentSize()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        if isPresentedAsForm {
            scrollView.bounces = true

            coordinator.animate(alongsideTransition: { (_) in
                self.scrollView.contentInset = UIEdgeInsets.zero
                self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            }, completion: nil)
        } else {
            scrollView.bounces = false
        }
    }

    // MARK: Custom methods

    func setPreferredContentSize() {
        var contentSize = scrollView.contentSize
        contentSize.width = view.frame.width
        preferredContentSize = contentSize
    }
}

extension SlideInViewController: KeyboardFrameChangesObserver {
    func willChangeKeyboardFrame(height: CGFloat, animationDuration: TimeInterval, animationOptions: UIView.AnimationOptions) {
        if traitCollection.verticalSizeClass == .compact && traitCollection.horizontalSizeClass == .compact {
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }, completion: nil)
        }
    }
}
