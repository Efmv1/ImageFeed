import Foundation

final class ProfileImageService {
    struct UserResult: Codable {
        let items: [String: String]
        
        private enum CodingKeys: String, CodingKey {
            case items = "profile_image"
        }
    }
    
    enum ProfileImageServiceError: Error {
        case invalidRequest
        case unwrappingError
    }
    
    static let shared = ProfileImageService()
    private init() {}
    
    private (set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String?, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else {
            print("Запрос уже выполняется")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let request = createProfileImageRequest(username) else {
            assertionFailure("Failed to create URL")
            return
        }
        let task = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("[ProfileImageService]: \(error.localizedDescription)")
                    completion(.failure(error))
                case .success(let response):
                    let smallURL = response.items["small"]
                    self?.avatarURL = smallURL
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": smallURL as Any])
                    completion(.success(smallURL))
                }
                self?.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func createProfileImageRequest(_ username: String) -> URLRequest? {
        let url = URL(string: "\(Constants.defaultBaseURL?.absoluteString ?? "https://api.unsplash.com")/users/\(username)")
        
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = url
        else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        return request
    }
}
