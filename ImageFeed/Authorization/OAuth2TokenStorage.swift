//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    private let tokenKey = "OAuth2Token"
}
