import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    private enum httpMethods: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[OAuthService]: Request already in work")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let url = makeOAuthTokenURL(code: code) else {
            fatalError("[OAuthService]: Failed to create URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethods.post.rawValue
        
        let task = URLSession.shared.objectTask(for: request
        ){ [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response.accessToken))
                case .failure(let error):
                    print("[OAuth2Service]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastCode = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func makeOAuthTokenURL(code: String) -> URL? {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")]
        
        return urlComponents?.url
    }
}
