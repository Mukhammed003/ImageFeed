//
//  ProfileViewSpy.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 31.07.2025.
//

@testable import ImageFeed
import Foundation

final class ProfileViewSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?

    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false

    var name: String?
    var login: String?
    var bio: String?
    var avatarURL: URL?

    func updateProfileDetails(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
        self.name = name
        self.login = login
        self.bio = bio
    }

    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
        self.avatarURL = url
    }
}
