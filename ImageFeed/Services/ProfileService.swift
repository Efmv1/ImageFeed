import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    
    private var task: URLSessionTask?
    var profileInfo: Profile?
    
    
    struct ProfileResult: Decodable {
        let username: String
        var name: String
        let bio: String?
    }
    
    struct Profile {
        let username: String
        let name: String
        var loginName: String {
            "@\(username)"
        }
        let bio: String?
    }
    
    enum ProfileServiceError: Error {
        case invalidRequest
    }
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard task == nil else {
            print("[ProfileService]: Request already in work")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        guard let request = createProfileRequest() else {
            assertionFailure("[ProfileService]: Failed to create URL")
            return
        }
        let task = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let profile = Profile(username: data.username,
                                          name: data.name,
                                          bio: data.bio)
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func createProfileRequest() -> URLRequest? {
        let url = URL(string: "\(Constants.defaultBaseURL?.absoluteString ?? "https://api.unsplash.com")/me")
        
        guard
            let token = OAuth2TokenStorage.shared.token,
            let url = url
        else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        return request
    }
}
