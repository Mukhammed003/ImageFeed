//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 31.07.2025.
//

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var avatarDidChangeCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }

    func avatarDidChange() {
        avatarDidChangeCalled = true
    }
}
