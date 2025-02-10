import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let showImageListSegueIdentifier = "ShowImageList"
    private let tokenStorage = OAuth2TokenStorage()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tokenStorage.token != nil {
            performSegue(withIdentifier: showImageListSegueIdentifier, sender: nil)
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
}
