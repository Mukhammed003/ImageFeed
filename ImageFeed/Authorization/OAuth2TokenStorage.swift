//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
