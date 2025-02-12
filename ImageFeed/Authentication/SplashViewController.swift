import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let showImageListSegueIdentifier = "ShowImageList"
    private let tokenStorage = OAuth2TokenStorage.shared
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        performSegue(withIdentifier: tokenStorage.token != nil ? showImageListSegueIdentifier : showAuthViewSegueIdentifier , sender: nil)
    }
}
