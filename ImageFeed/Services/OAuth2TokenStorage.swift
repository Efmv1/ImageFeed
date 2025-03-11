import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    enum OAuthTokenStorageError: Error {
        case savingError
    }
    static let shared = OAuth2TokenStorage()
    private init () {}
    
    private let tokenKey = "token"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "Auth token")
        }
        set {
            guard let token = newValue else { return }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
            guard isSuccess else {
                print(OAuthTokenStorageError.savingError)
                return
            }
        }
    }
    
    func newToken(_ value: String){
        token = value
    }
}
