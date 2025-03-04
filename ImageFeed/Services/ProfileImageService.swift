import Foundation

final class ProfileImageService {
    struct UserResult: Codable {
        let images: [String]
        
        private enum CodingKeys: String, CodingKey {
            case images = "profile_image"
        }
    }
    
//    struct UserImage: Codable {
//        let image: URL?
//        
//        private enum CodingKeys: String, CodingKey {
//            case image = "small"
//        }
//    }
    
    enum ProfileImageServiceError: Error {
        case invalidRequest
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
        
        guard let request = createProfileImageRequest(username) else { return }
        let task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(UserResult.self, from: data)
                        self?.avatarURL = response.images.first
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": response.images.first])
                        completion(.success(response.images.first))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                }
                self?.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func createProfileImageRequest(_ username: String) -> URLRequest? {
        let url = URL(string: "\(Constants.defaultBaseURL?.absoluteString ?? "https://api.unsplash.com")/users/:\(username)")
        
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = url
        else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        return request
    }
}
