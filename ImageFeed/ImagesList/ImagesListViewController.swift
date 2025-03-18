import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private let imagesService = ImagesListService.shared
    private var imagesServiceObserver: NSObjectProtocol?
    private var photos: [ImagesListService.Photo] = []
    
    private let dateDecoder = ISO8601DateFormatter()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesService.photos.count
        if oldCount != newCount {
            tableView.performBatchUpdates {
                photos = imagesService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesService.fetchPhotosNextPage()
        
        imagesServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let index = sender as? Int
            else {
                assertionFailure("[ImageListViewController]: Invalid segue destination")
                return
            }
            
            viewController.imageURL = photos[index].largeImageURL
            UIBlockingProgressHUD.show()
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.delegate = self
        
        cell.imageTab.kf.indicatorType = .activity
        cell.imageTab.kf.setImage(
            with: URL(string: photos[indexPath.row].thumbImageURL),
            placeholder: UIImage(named: "imageStub")){ [weak self] result in
                guard let self else { return }
                switch result {
                case .success(_):
                    self.tableView.reloadRows(at: [indexPath], with: .none)
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


// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: index)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let posterImage = UIImageView()
        posterImage.kf.setImage(with: URL(string: photos[indexPath.row].thumbImageURL))
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard
            let imageWidth = posterImage.image?.size.width,
            let imageHeight = posterImage.image?.size.height
        else { return 100 }
        
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
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
                    print("[ImagesListViewController]: \(error.localizedDescription)")
                    
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
        
    }
}
