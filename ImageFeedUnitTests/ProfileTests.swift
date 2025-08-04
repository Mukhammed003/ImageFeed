//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 31.07.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsUpdateProfileDetails() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()

        ProfileService.shared.profile = Profile(
                username: "johndoe",
                name: "John Doe",
                loginName: "@johndoe",
                bio: "iOS Developer"
            )

        presenter.view = view
        presenter.viewDidLoad()

        XCTAssertTrue(view.updateProfileDetailsCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()

        ProfileService.shared.profile = Profile(
                username: "johndoe",
                name: "John Doe",
                loginName: "@johndoe",
                bio: "iOS Developer"
            )
        ProfileImageService.shared.avatarURL = "https://example.com/avatar.png"

        presenter.view = view
        presenter.viewDidLoad()

        XCTAssertTrue(view.updateAvatarCalled)
    }

    func testPresenterCallsDidTapLogout() {
        let presenter = ProfilePresenterSpy()

        presenter.didTapLogout()

        XCTAssertTrue(presenter.didTapLogoutCalled)
    }

    func testPresenterCallsAvatarDidChange() {
        let presenter = ProfilePresenterSpy()

        presenter.avatarDidChange()

        XCTAssertTrue(presenter.avatarDidChangeCalled)
    }
    
    func testPresenterProvidesCorrectProfileData() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()
        
        let testProfile = Profile(
            username: "janedoe",
            name: "Jane Doe",
            loginName: "@janedoe",
            bio: "Test Bio"
        )
        ProfileService.shared.profile = testProfile
        
        presenter.view = view
        presenter.viewDidLoad()
        
        XCTAssertEqual(view.name, testProfile.name)
        XCTAssertEqual(view.login, testProfile.loginName)
        XCTAssertEqual(view.bio, testProfile.bio)
    }
    
    func testPresenterPassesCorrectAvatarURL() {
        let view = ProfileViewSpy()
        let presenter = ProfilePresenter()

        let avatarURLString = "https://example.com/avatar.jpg"
        ProfileImageService.shared.avatarURL = avatarURLString

        ProfileService.shared.profile = Profile(
            username: "janedoe",
            name: "Jane Doe",
            loginName: "@janedoe",
            bio: "iOS Developer"
        )

        presenter.view = view
        presenter.viewDidLoad()

        XCTAssertEqual(view.avatarURL, URL(string: avatarURLString))
    }
}
