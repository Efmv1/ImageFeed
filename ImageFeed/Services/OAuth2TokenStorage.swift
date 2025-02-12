import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init () {}
    
    private let tokenKey = "token"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey) ?? nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    func newToken(_ value: String){
        token = value
    }
}
