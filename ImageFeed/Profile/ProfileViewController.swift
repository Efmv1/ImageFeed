import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Private Properties
    var imageView: UIImageView = {
        let image = UIImage(named: "stub")
        let view = UIImageView(image: image)
        return view
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = .boldSystemFont(ofSize: 23)
        return label
    }()
    
    var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    var exitButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(named: "exitPicture") ?? UIImage(),
                                           target: self,
                                           action: #selector(didExitButtonTaped))
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "exitButton"
        return button
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var presenter: ProfileViewPresenterProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.presenter?.profileImageDidLoad()
            }
        presenter?.profileImageDidLoad()
        
        presenter?.presentProfile()
    }
    
    // MARK: - Private Methods
    @objc private func didExitButtonTaped() {
        presenter?.didExitButtonTaped()
    }
    
    // MARK: - Public Methods
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.controller = self
    }
    
    func show(_ alert: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func logout() {
        dismiss(animated: true)
    }
}

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    var imageView: UIImageView { get set }
    var nameLabel: UILabel { get set }
    var nicknameLabel: UILabel { get set }
    var statusLabel: UILabel { get set }
    var exitButton: UIButton { get set }
    var view: UIView! { get set }
    
    func show(_ alert: UIAlertController)
    func logout()
}
