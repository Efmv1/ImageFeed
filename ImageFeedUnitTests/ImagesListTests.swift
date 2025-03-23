import XCTest
@testable import ImageFeed

final class ImageImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.controller = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerUpdatingPhotos() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.controller = viewController
        
        //when
        viewController.presenter?.updatePhotos()
        
        //then
        XCTAssertTrue(presenter.photosDidUpdated)
    }
    
    func testViewControllerCalculateHeight() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.controller = viewController
        
        //when
        viewController.tableView(UITableView(), heightForRowAt: IndexPath(row: 0, section: 0))
        
        //then
        XCTAssertTrue(presenter.heightForRowAtCalled)
    }
}
