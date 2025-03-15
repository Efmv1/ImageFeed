import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    
    private(set) var lastLoadedPage: Int?
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        let nextPage = lastLoadedPage ?? 0 + 1
        
        assert(Thread.isMainThread)
        guard task == nil else {
            print("[ImagesListService]: Request already in work")
            return
        }
        
        guard let request = createImageListRequest(nextPage) else {
            assertionFailure("[ImagesListService]: Failed to create URL")
            return
        }
        
        let task = URLSession.shared.objectTask(
            for: request
        ){ [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    response.forEach { item in
                        self.photos.append(Photo(id: item.id,
                                                 size: CGSize(width: item.width, height: item.height),
                                                 createdAt: item.createdAt,
                                                 welcomeDescription: item.description,
                                                 thumbImageURL: item.urls["thumb"] ?? "",
                                                 largeImageURL: item.urls["full"] ?? "",
                                                 isLiked: item.isLiked))
                    }
                    
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photos": self.photos as Any])
                case .failure(let error):
                    print("[ImagesListService]: \(error.localizedDescription)")
                }
                self.task = nil
                guard var lastLoadedPage = self.lastLoadedPage else { return }
                lastLoadedPage += 1
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func createImageListRequest(_ page: Int) -> URLRequest? {
        let url = URL(string: "https://api.unsplash.com/photos?page=\(page)")
        
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = url
        else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: String
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
    }
    
    struct PhotoResult: Codable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: String
        let description: String?
        let urls: [String: String]
        let isLiked: Bool
        
        private enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case createdAt = "created_at"
            case description
            case urls
            case isLiked = "liked_by_user"
        }
    }
}

