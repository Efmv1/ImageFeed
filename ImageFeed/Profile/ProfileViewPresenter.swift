import Foundation
import UIKit
import Kingfisher

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private let profileService = ProfileService.shared
    private let logoutService = ProfileLogoutService.shared
    
    var controller: ProfileViewControllerProtocol?
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.controller?.imageView.kf.indicatorType = .activity
            let processor = RoundCornerImageProcessor(cornerRadius: 61)
            self.controller?.imageView.kf.setImage(with: url,
                                                   options: [.processor(processor)])
        }
    }
    
    func profileImageDidLoad() {
        updateAvatar()
    }
    
    func presentProfile() {
        updateProfileDetails()
        
        guard
            let view = controller?.view,
            let imageView = controller?.imageView,
            let nameLabel = controller?.nameLabel,
            let nicknameLabel = controller?.nicknameLabel,
            let statusLabel = controller?.statusLabel,
            let exitButton = controller?.exitButton
        else { return }
        view.backgroundColor = .ypBlack
        
        [imageView, nameLabel, nicknameLabel, statusLabel].forEach{
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            nicknameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            statusLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8)
        ])
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
    
    func didExitButtonTaped() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] _ in
            guard let view = self?.controller?.view else { return }
            for view in view.subviews {
                view.removeFromSuperview()
            }
            
            self?.logoutService.logout()
            self?.controller?.logout()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        controller?.show(alert)
    }
    
    private func updateProfileDetails() {
        controller?.nameLabel.text = profileService.profileInfo?.name
        controller?.nicknameLabel.text = profileService.profileInfo?.loginName
        controller?.statusLabel.text = profileService.profileInfo?.bio
    }
}

protocol ProfileViewPresenterProtocol: AnyObject {
    var controller: ProfileViewControllerProtocol? { get set }
    
    func updateAvatar()
    func profileImageDidLoad()
    func presentProfile()
    func didExitButtonTaped()
}
