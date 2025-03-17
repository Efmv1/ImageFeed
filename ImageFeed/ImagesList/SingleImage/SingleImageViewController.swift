import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private var backButton: UIButton!
    @IBOutlet var fullscreenImage: UIImageView!
    
    @IBOutlet private var shareButton: UIButton!
    
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        
        guard let url = imageURL else { return }
        fullscreenImage.kf.indicatorType = .activity
        fullscreenImage.kf.setImage(with: URL(string: url)) { [weak self] result in
            switch result {
            case .success:
                guard let image = self?.fullscreenImage.image else { return }
                self?.fullscreenImage.frame.size = image.size
                self?.rescaleAndCenterImageInScrollView(image: image)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("[SingleImageViewController]: \(error.localizedDescription)")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = fullscreenImage.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - Public Properties
    var imageURL: String?
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        fullscreenImage
    }
}
