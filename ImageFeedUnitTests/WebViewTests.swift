//
//  ImageFeedUnitTests.swift
//  ImageFeedUnitTests
//
//  Created by Muhammed Nurmukhanov on 30.07.2025.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCalledLoadRequest() {
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        let shoulHideProgress = presenter.shouldHideProgess(for: progress)
        
        XCTAssertFalse(shoulHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgess(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        guard let url = authHelper.authURL() else { return }
        let urlString = url.absoluteString
        
        XCTAssertTrue(urlString.contains(configuration.unsplashAuthorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
    }
    
    func testCodeFromURL() {
        let authHelper = AuthHelper()
        
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native") else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        
        guard let url = urlComponents.url else { return }
        let result = authHelper.code(from: url)
        
        XCTAssertEqual("test code", result)
    }
}


