//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 31.07.2025.
//

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func avatarDidChange()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let logoutService = ProfileLogoutService.shared

    func viewDidLoad() {
        guard let profile = profileService.profile else {
            print("❌ Ошибка: профиль не найден")
            return
        }

        view?.updateProfileDetails(
            name: profile.name,
            login: profile.loginName,
            bio: profile.bio
        )

        if let urlString = profileImageService.avatarURL,
           let url = URL(string: urlString) {
            view?.updateAvatar(with: url)
        }
    }

    func avatarDidChange() {
        if let urlString = profileImageService.avatarURL,
           let url = URL(string: urlString) {
            view?.updateAvatar(with: url)
        }
    }

    func didTapLogout() {
        logoutService.logout()
    }
}
