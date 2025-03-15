import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    
    private(set) var lastLoadedPage: Int?
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    enum ImagesListServiceError: Error {
        case invalidRequest
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        let nextPage = lastLoadedPage ?? 0 + 1
        
        assert(Thread.isMainThread)
        guard task == nil else {
            print("[ImagesListService]: Request already in work")
            completion(.failure(ImagesListServiceError.invalidRequest))
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
                    for item in response {
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
                    completion(.success(self.photos))
                case .failure(let error):
                    print("[ImagesListService]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func createImageListRequest(_ page: Int) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURL?.absoluteString ?? "https://api.unsplash.com")/photos?page=\(page)") else { return nil }
        
        let request = URLRequest(url: url)
        return request
    }
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
    }
    
    struct PhotoResult: Codable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: Date?
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
