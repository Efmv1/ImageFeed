import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let showImageListSegueIdentifier = "ShowImageList"
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tokenStorage.token != nil {
            profileService.fetchProfile() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self.profileService.profileInfo = data
                    profileImageService.fetchProfileImageURL(username: data.username) { result in
                        switch result {
                        case .success(let urlString):
                            break
                        case .failure(let error):
                            print(error)
                        }
                    }
                    performSegue(withIdentifier: showImageListSegueIdentifier, sender: nil)
                }
            }
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
}
