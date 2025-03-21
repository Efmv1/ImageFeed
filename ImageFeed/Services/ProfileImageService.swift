import Foundation

final class ProfileImageService {
    enum ProfileImageServiceError: Error {
        case invalidRequest
        case unwrappingError
    }
    
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String?, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else {
            print("[ProfileImageService]: Request already in work")
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let request = createProfileImageRequest(username) else {
            fatalError("[ProfileImageService]: Failed to create URL")
        }
        let task = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let url = response.items["large"]
                    self?.avatarURL = url
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": url as Any])
                    completion(.success(url))
                case .failure(let error):
                    print("[ProfileImageService]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func logoutProfile() {
        avatarURL = nil
        
        ProfileService.shared.profileInfo = nil
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
