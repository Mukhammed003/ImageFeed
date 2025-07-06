//
//  AppDelegate.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 18.05.2025.
//

import UIKit
import SwiftKeychainWrapper

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
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

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func clearKeychainIfFirstLaunch() {
            let defaults = UserDefaults.standard
            let hasLaunchedBefore = defaults.bool(forKey: "hasLaunchedBefore")
            
            if !hasLaunchedBefore {
                KeychainWrapper.standard.removeAllKeys()
                defaults.set(true, forKey: "hasLaunchedBefore")
                print("🧼 Keychain очищен при первом запуске.")
            }
        }


}

