//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 12.07.2025.
//

import Foundation

final class ImagesListService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private let storage = OAuth2TokenStorage.shared
    private let dateFormatter = ISO8601DateFormatter()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        assert(Thread.isMainThread)
        if task != nil || lastLoadedPage == nextPage {
            return
        }
        
        guard
            let request = makeRequestForGettingListOfPhotos(nextPage) else {
            print("[ImagesListService.fetchPhotosNextPage]: Failure - Request creation error")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            
            guard let self = self else { return }
            
            defer {
                self.task = nil
            }
            
            switch result {
            case .success(let photoResult):
                self.lastLoadedPage = nextPage
                let photo = photoResult.map(self.convertToPhoto)
                self.updatePhotoList(newPhotosList: photo)
                print("[ImagesListService.fetchPhotosNextPage]: Success - Photos received")
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: Failure - \(error.localizedDescription)")
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequestForGettingListOfPhotos(_ page: Int) -> URLRequest? {
        var components = URLComponents()
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "order_by", value: "latest")
        ]
        
        guard let baseURL = URL(string: "https://api.unsplash.com"), let url = components.url(relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        guard let token = storage.token else {
            print("[ProfileImageService.makeRequestForGettingUserImage]: Failure - no token available")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        
        return request
    }
    
    private func convertToPhoto(photoResult: PhotoResult) -> Photo {
        let createdAt = photoResult.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: createdAt,
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser)
    }
    
    private func updatePhotoList(newPhotosList: [Photo]) {
        DispatchQueue.main.async {
            let existingIDs = Set(self.photos.map { $0.id })
            let uniquePhotos = newPhotosList.filter { !existingIDs.contains($0.id) }
            
            guard !uniquePhotos.isEmpty else {
                print("⚠️ No unique photos to add")
                return
            }
            
            self.photos.append(contentsOf: uniquePhotos)
            self.postPhotosChangedNotification()
        }
    }
    
    private func postPhotosChangedNotification() {
        NotificationCenter.default
            .post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["photos": self.photos]
            )
    }
}
