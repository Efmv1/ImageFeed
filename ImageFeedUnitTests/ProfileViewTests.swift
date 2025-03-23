import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.controller = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.profileImageDidLoadCalled)
        XCTAssertTrue(presenter.presentProfileCalled)
    }
}
