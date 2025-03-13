import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init () {}
    
    private let tokenKey = "Auth token"
    
    private(set) var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let token = newValue else { return }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
            guard isSuccess else {
                print("[OAuthTokenStorage]: Saving error")
                return
            }
        }
    }
    
    func newToken(_ value: String){
        token = value
    }
}
