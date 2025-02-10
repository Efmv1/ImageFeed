import Foundation

final class OAuth2TokenStorage {
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token") ?? nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    
    func newToken(value: String){
        token = value
    }
}
