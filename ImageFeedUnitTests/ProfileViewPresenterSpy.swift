import Foundation
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var controller: ProfileViewControllerProtocol?
    
    var presentProfileCalled = false
    var profileImageDidLoadCalled = false
    var didExitButtonTapedCalled = false
    
    func updateAvatar() {
        
    }
    
    func profileImageDidLoad() {
        profileImageDidLoadCalled = true
    }
    
    func presentProfile() {
        presentProfileCalled = true
    }
    
    func didExitButtonTaped() {
        didExitButtonTapedCalled = true
    }
    
    
}
