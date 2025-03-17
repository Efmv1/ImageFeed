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
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

