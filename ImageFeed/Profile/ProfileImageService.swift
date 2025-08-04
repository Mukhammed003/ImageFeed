//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 22.06.2025.
//

import Foundation

enum ProfileImageServiceError: Error {
    case invalidRequest
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    internal(set) var avatarURL: String?
    
    private init() {}
    
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void) {
            assert(Thread.isMainThread)
            if task != nil {
                if lastUsername != username {
                    task?.cancel()
                } else {
                    completion(.failure(ProfileImageServiceError.invalidRequest))
                    return
                }
            } else {
                if lastUsername == username {
                    completion(.failure(ProfileImageServiceError.invalidRequest))
                    return
                }
            }
            lastUsername = username
            
            guard
                let request = makeRequestForGettingUserImage(userName: username) else {
                print("[ProfileImageService.fetchProfileImageURL]: Failure - Request creation error")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
                
                guard let self = self else { return }
                
                defer {
                    self.task = nil
                    self.lastUsername = nil
                }
                
                switch result {
                case .success(let userInfo):
                    guard let avatarURL = userInfo.profileImage.large else {
                        print("[ProfileImageService.fetchProfileImageURL]: Failure - missing avatarURL from profileImage.large")
                        return
                    }
                    self.avatarURL = avatarURL
                    print("[ProfileImageService.fetchProfileImageURL]: Success - Profile avater received: \(avatarURL)")
                    completion(.success(avatarURL))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL])
                case .failure(let error):
                    print("[ProfileImageService.fetchProfileImageURL]: Failure - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            self.task = task
            task.resume()
        }
    
    func removeAvatarURL() {
        self.avatarURL = nil
    }
    
    private func makeRequestForGettingUserImage(userName: String) -> URLRequest? {
        var components = URLComponents()
        components.path = "/users/\(userName)"
        
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
}
