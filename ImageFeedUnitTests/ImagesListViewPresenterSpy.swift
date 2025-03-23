import Foundation
@testable import ImageFeed

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var controller: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    var photosDidUpdated = false
    var heightForRowAtCalled = false
    
    func updatePhotos() {
        photosDidUpdated = true
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        heightForRowAtCalled = true
        return 0
    }
    
    func fetchNextPage() {
        
    }
    
    func prepareCell(_ cell: ImagesListCell, forRowAt indexPath: IndexPath) {
        
    }
}
