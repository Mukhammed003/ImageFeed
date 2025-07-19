//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 19.07.2025.
//

import Foundation
import WebKit


final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imageListService = ImagesListService.shared
    
    private init() {}
    
    func logout() {
        cleanCookies()
        storage.token = nil
        profileService.clearProfile()
        profileImageService.removeAvatarURL()
        imageListService.clearPhotos()
        
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date())
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})}
        }
    }
}
