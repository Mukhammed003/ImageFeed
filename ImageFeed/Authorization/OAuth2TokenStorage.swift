//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    private init() {}

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    private let tokenKey = "OAuth2Token"
}
