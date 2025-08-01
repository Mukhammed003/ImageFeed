//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 01.08.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterReturnsCorrectPhoto() {
        let presenter = ImagesListPresenterSpy()
        let mockPhoto = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "url", largeImageURL: "url", isLiked: false)
        
        presenter.photos = [mockPhoto]
        
        let returnedPhoto = presenter.photo(at: 0)
        
        XCTAssertEqual(returnedPhoto.id, "1")
        XCTAssertEqual(returnedPhoto.thumbImageURL, "url")
    }
    
    func testPhotosCountMatchesPresenterPhotos() {
        let presenter = ImagesListPresenterSpy()
        presenter.photos = [
            Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false),
            Photo(id: "2", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        
        XCTAssertEqual(presenter.photosCount, 2)
    }
    
    func testDidTapLikeCallsViewReload() {
        let view = ImagesListViewSpy()
        let presenter = ImagesListPresenterSpy()
        presenter.view = view
        presenter.photos = [
            Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        
        presenter.didTapLike(at: 0)
        
        XCTAssertTrue(view.didCallReloadCell)
    }
}
