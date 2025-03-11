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
        super.viewDidAppear(animated)
        
        presentSplashView()
        
        if tokenStorage.token != nil {
            profileService.fetchProfile() { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    self.profileService.profileInfo = data
                    profileImageService.fetchProfileImageURL(username: data.username) { error in
                        print(error)
                    }
                }
                showTabBar()
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
        
        
        let navigationController = storyboard.instantiateViewController(
            withIdentifier: "NavigationController"
        )
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        showTabBar()
    }
}
