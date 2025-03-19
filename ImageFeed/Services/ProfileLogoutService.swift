import Foundation
import WebKit


final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanCache()
    }
    
    private func cleanCache() {
        ImagesListService.shared.deletePhotos()
        
        ProfileImageService.shared.logoutProfile()
        
        OAuth2TokenStorage.shared.removeToken()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

