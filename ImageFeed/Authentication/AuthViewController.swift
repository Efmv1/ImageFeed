import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("[AuthViewController]: Invalid segue destination")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let tokenStorage = OAuth2TokenStorage.shared
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        configureBackButton()
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            vc.dismiss(animated: true)
            
            UIBlockingProgressHUD.show()
            self.oauth2Service.fetchOAuthToken(code: code) { result in
                switch result {
                case .failure(let error):
                    print("[AuthViewController]: \(error.localizedDescription)")
                    UIBlockingProgressHUD.dismiss()
                    let alert = UIAlertController(
                        title: "Что-то пошло не так",
                        message: "Не удалось войти в систему",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                case .success(let bearerToken):
                    self.tokenStorage.newToken(bearerToken)
                    UIBlockingProgressHUD.dismiss()
                    self.delegate?.didAuthenticate(self)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
