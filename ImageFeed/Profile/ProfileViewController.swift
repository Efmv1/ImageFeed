import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Private Properties
    private var imageView = UIImageView()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        presentProfilePhoto()
        
    }
    
    // MARK: - Private Methods
    private func presentProfilePhoto() {
        imageView.image = UIImage(named: "profilePhoto")
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        let nicknameLabel = UILabel()
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = .ypGray
        nicknameLabel.font = .systemFont(ofSize: 13)
        
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nicknameLabel)
        
        nicknameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        let statusLabel = UILabel()
        statusLabel.text = "Hello, world!"
        statusLabel.textColor = .ypWhite
        statusLabel.font = .systemFont(ofSize: 13)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        statusLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8).isActive = true
        
        let exitButton = UIButton.systemButton(with: UIImage(named: "exitPicture") ?? UIImage(),
                                               target: self,
                                               action: #selector(didExitButtonTaped))
        exitButton.tintColor = .ypRed
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
    
    @objc private func didExitButtonTaped() {
        for view in view.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
        
        imageView.image = UIImage(named: "stub")
    }
}
