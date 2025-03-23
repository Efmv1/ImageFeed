import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var imagesServiceObserver: NSObjectProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        
        imagesServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.presenter?.updatePhotos()
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let index = sender as? Int
            else {
                fatalError("[ImageListViewController]: Invalid segue destination")
            }
            
            viewController.imageURL = presenter?.photos[index].largeImageURL
            UIBlockingProgressHUD.show()
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Properties
    var presenter: ImagesListViewPresenterProtocol?
    
    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        presenter?.prepareCell(cell, forRowAt: indexPath)
    }
    
    func configure(_ presenter: ImagesListViewPresenterProtocol) {
        self.presenter = presenter
        presenter.controller = self
    }
}


// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: index)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellHeight = presenter?.heightForRowAt(indexPath: indexPath) else {
            fatalError("[ImageListViewController]: Could not get cell height")
        }
        
        return cellHeight
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter?.photos.count {
            presenter?.fetchNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = presenter?.photos.count else {
            fatalError("[ImageListViewController]: Could not get number of rows")
        }
        
        return numberOfRows
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

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    var tableView: UITableView! { get set }
}
