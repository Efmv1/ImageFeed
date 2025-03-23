import Foundation
import UIKit
import Kingfisher

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    var photos: [Photo] = []
    private let imagesService = ImagesListService.shared
    
    private let dateDecoder = ISO8601DateFormatter()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    var controller: ImagesListViewControllerProtocol?
    
    func viewDidLoad() {
        imagesService.fetchPhotosNextPage()
        
        controller?.tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func updatePhotos() {
        let oldCount = photos.count
        let newCount = imagesService.photos.count
        if oldCount != newCount {
            controller?.tableView.performBatchUpdates {
                photos = imagesService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                controller?.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        guard let tableView = controller?.tableView else {
            fatalError("[ImagesListViewPresenter]: tableView is nil")
        }
        
        let posterImage = UIImageView()
        DispatchQueue.main.async {
            posterImage.kf.setImage(with: URL(string: self.photos[indexPath.row].thumbImageURL))
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard
            let imageWidth = posterImage.image?.size.width,
            let imageHeight = posterImage.image?.size.height
        else { return 370 }
        
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func fetchNextPage() {
        imagesService.fetchPhotosNextPage()
    }
    
    func prepareCell(_ cell: ImagesListCell, forRowAt indexPath: IndexPath) {
        cell.delegate = self
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            cell.imageTab.kf.indicatorType = .activity
            cell.imageTab.kf.setImage(
                with: URL(string: self.photos[indexPath.row].thumbImageURL),
                placeholder: UIImage(named: "imageStub")){ [weak self] result in
                    switch result {
                    case .success(let image):
                        if cell.imageTab.image != image.image {
                            cell.imageTab.image = image.image
                            self?.controller?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    case .failure(let error):
                        print("[ImageListViewController]: \(error.localizedDescription)")
                    }
                }
            
            
            guard let date = dateDecoder.date(from: photos[indexPath.row].createdAt)
            else { return }
            cell.dateLabel.text = dateFormatter.string(from: date)
            
            cell.likeButton.setTitle("", for: .normal)
            if photos[indexPath.row].isLiked == true {
                cell.likeButton.setImage(UIImage(named: "active"), for: .normal)
            } else {
                cell.likeButton.setImage(UIImage(named: "nonActive"), for: .normal)
            }
        }
    }
}

extension ImagesListViewPresenter: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = controller?.tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesService.changeLike(photoId: photo.id,
                                 isLike: !photo.isLiked
        ){ result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.photos = self.imagesService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    print("[ImagesListViewPresenter]: \(error.localizedDescription)")
                    
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
}


protocol ImagesListViewPresenterProtocol: AnyObject {
    var controller: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    
    func updatePhotos()
    func viewDidLoad()
    func heightForRowAt(indexPath: IndexPath) -> CGFloat
    func fetchNextPage()
    func prepareCell(_ cell: ImagesListCell, forRowAt indexPath: IndexPath)
}
