//
//  ImagesListViewSpy.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 01.08.2025.
//

@testable import ImageFeed
import Foundation

final class ImagesListViewSpy: ImagesListViewProtocol {
    var presenter: ImagesListPresenterProtocol?
    var didCallReloadCell = false

    func updateTableViewAnimated() {}

    func reloadCell(at indexPath: IndexPath) {
        didCallReloadCell = true
    }

    func showLikeError(message: String) {}
}
