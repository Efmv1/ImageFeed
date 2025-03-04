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
        
        private enum CodingKeys: String, CodingKey {
            case username = "username"
            case name = "name"
            case bio = "bio"
        }
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
            print("Запрос уже выполняется")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        guard let request = createProfileRequest() else { return }
        let task = URLSession.shared.objectTask(for: request, decoder: ProfileResult) {result in
            switch result {
            case .success(let data):
                let profile = data
            case .failure(let error):
                print(error)
            }
            
            //        let task = URLSession.shared.data(for: request) { [weak self] result in
            //            DispatchQueue.main.async {
            //                switch result {
            //                case .failure(let error):
            //                    print(error)
            //                    completion(.failure(error))
            //                case .success(let data):
            //                    do {
            //                        let response = try JSONDecoder().decode(ProfileResult.self, from: data)
            //                        let profile = Profile(username: response.username,
            //                                              name: response.name,
            //                                              bio: response.bio)
            //                        completion(.success(profile))
            //                    } catch {
            //                        print(error)
            //                        completion(.failure(error))
            //                    }
            //                }
            self?.task = nil
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
