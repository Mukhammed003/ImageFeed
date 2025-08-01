//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 01.08.2025.
//

@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    var view: ImagesListViewProtocol?
    var viewDidLoadCalled = false
    var photos: [Photo] = []

    var photosCount: Int {
        return photos.count
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photo(at index: Int) -> Photo {
        return photos[index]
    }

    func configCell(_ cell: ImagesListCell, for index: Int) {
        let photo = photo(at: index)
        cell.setIsLiked(photo.isLiked)
        cell.dateLabel?.text = "Test Date"
    }

    func didSelectImage(at index: Int) { }

    func didTapLike(at index: Int) {
        view?.reloadCell(at: IndexPath(row: index, section: 0))
    }
    
    func sizeForPhoto(at index: Int) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
