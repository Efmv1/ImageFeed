import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var vectorImage: UIImageView = {
        let image = UIImage(named: "vector")
        let view = UIImageView(image: image)
        return view
    }()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        presentSplashView()
        
        if tokenStorage.token != nil {
            UIBlockingProgressHUD.show()
            ImagesListService.shared.fetchPhotosNextPage()
            profileService.fetchProfile() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.showTabBar()
                    self.profileService.profileInfo = data
                    self.profileImageService.fetchProfileImageURL(username: data.username)
                    { result in
                        switch result {
                        case .success(_):
                            break
                        case .failure(let error):
                            print("[SplashViewController]: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("[SplashViewController]: \(error.localizedDescription)")
                }
            }
        } else {
            showAuthView()
        }
    }
    
    private func presentSplashView() {
        view.backgroundColor = .ypBlack
        
        vectorImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vectorImage)
        
        NSLayoutConstraint.activate([
            vectorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            vectorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        ])
    }
    
    private func showTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "TabBarController"
        )
        
        tabBarController.modalPresentationStyle = .fullScreen
        
        present(tabBarController, animated: true)
    }
    
    private func showAuthView() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        
        show(authViewController, sender: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        showTabBar()
    }
}
