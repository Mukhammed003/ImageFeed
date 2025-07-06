//
//  UserDefaultsService.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 06.07.2025.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }

    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Key.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Key.hasLaunchedBefore) }
    }
}
