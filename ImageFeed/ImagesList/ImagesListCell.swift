import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageTab.kf.cancelDownloadTask()
    }
    
    // MARK: - Outlets
    @IBOutlet var imageTab: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
}
