import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                fatalError("[AuthViewController]: Invalid segue destination")
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            viewController.presenter = webViewPresenter
            webViewPresenter.view = viewController
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        configureBackButton()
        
        print("\(String(describing: delegate))")
    }
    
    // MARK: - Private Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button_white")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button_white")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    //MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.newToken(token)
                UIBlockingProgressHUD.dismiss()
                delegate?.didAuthenticate()
            case .failure(let error):
                print("[AuthViewController]: \(error.localizedDescription)")
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
