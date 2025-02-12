import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
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
    
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = makeOAuthTokenURL(code: code) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethods.post.rawValue
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .failure(let error):
                print(error)
                completion(.failure(error))
            case .success(let data):
                do {
                    let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(token.accessToken))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
        }
        
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
