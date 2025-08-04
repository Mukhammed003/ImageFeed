//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 01.08.2025.
//

import Foundation
import Kingfisher
import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }

    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func sizeForPhoto(at index: Int) -> CGSize
    func configCell(_ cell: ImagesListCell, for index: Int)
    func didSelectImage(at index: Int)
    func didTapLike(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private var imagesListService = ImagesListService.shared
    private let dateFormatter = AppDateFormatters.photoListFormatter

    internal(set) var photos: [Photo] = []

    var photosCount: Int {
        photos.count
    }

    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()

        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            self.photos = self.imagesListService.photos
            self.view?.updateTableViewAnimated()
        }
    }

    func photo(at index: Int) -> Photo {
        return photos[index]
    }

    func sizeForPhoto(at index: Int) -> CGSize {
        return photos[index].size
    }

    @MainActor func configCell(_ cell: ImagesListCell, for index: Int) {
        let photo = photo(at: index)
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        if let url = URL(string: photo.thumbImageURL) {
            cell.imageOfPost?.kf.indicatorType = .activity
            cell.imageOfPost?.kf.setImage(with: url,
                                          placeholder: UIImage(resource: .placeholderImageForPost),
                                          options: [.processor(processor)])
        }

        cell.dateLabel?.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.setIsLiked(photo.isLiked)
    }

    func didSelectImage(at index: Int) {
    }

    func didTapLike(at index: Int) {
        let photo = photo(at: index)
        let newLikeStatus = !photo.isLiked

        UIBlockingProgressHUD.show()

        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }

            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.reloadCell(at: IndexPath(row: index, section: 0))
            case .failure(let error):
                self.view?.showLikeError(message: error.localizedDescription)
            }
        }
    }
}
