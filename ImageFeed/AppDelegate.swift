//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 18.05.2025.
//

import UIKit
import SwiftKeychainWrapper

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDefaultsService = UserDefaultsService.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        clearKeychainIfFirstLaunch()
        return true
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        let sceneConfiguration = UISceneConfiguration(
            name: "Main",
            sessionRole: connectingSceneSession.role)
        
        sceneConfiguration.delegateClass = SceneDelegate.self
        
        return sceneConfiguration
    }
    
    private func clearKeychainIfFirstLaunch() {
        
        if !userDefaultsService.hasLaunchedBefore {
            KeychainWrapper.standard.removeAllKeys()
            userDefaultsService.hasLaunchedBefore = true
            print("🧼 Keychain очищен при первом запуске.")
        }
    }


}

