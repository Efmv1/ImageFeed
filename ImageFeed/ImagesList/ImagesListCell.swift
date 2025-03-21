import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTab.kf.cancelDownloadTask()
        imageTab.image = nil
    }
    
    // MARK: - Outlets
    @IBOutlet var imageTab: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    
    @IBAction func didTapLikeButton(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Public Methods
    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(UIImage(named: isLiked ? "active" : "nonActive"), for: .normal)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
