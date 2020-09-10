import UIKit
import Optile

class ViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTintColor(to: .navigationBarTintColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let pasteText = UIPasteboard.general.string, let _ = URL(string: pasteText) {
            // Paste URL from clipboard automatically
            textField.text = pasteText
        } else {
            textField.becomeFirstResponder()
        }
    }

    @IBAction func switchValueDidChange(_ sender: UISwitch) {
        if sender.isOn {
            Theme.shared = .custom
            setNavigationBarTintColor(to: .blue)
        } else {
            Theme.shared = .standard
            setNavigationBarTintColor(to: .navigationBarTintColor)
        }
    }

    @IBAction func sendRequest(_ sender: Any) {
        guard let text = textField.text, let url = URL(string: text) else {
            print("Invalid URL")
            textField.text = nil
            return
        }

        let viewController = List.ViewController(listResultURL: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension ViewController {
    func setNavigationBarTintColor(to color: UIColor) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = color
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController?.navigationBar.setNeedsLayout()
            navigationController?.navigationBar.layoutIfNeeded()
        } else {
            navigationController?.navigationBar.barTintColor = color
        }
    }
}

private extension UIColor {
    static var navigationBarTintColor: UIColor {
        return UIColor(red: 0.0, green: 137.0 / 255.0, blue: 64.0 / 255.0, alpha: 1.0)
    }
}
