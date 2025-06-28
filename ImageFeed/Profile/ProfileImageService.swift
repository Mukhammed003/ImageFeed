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
    
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private (set) var avatarURL: String?
    
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
                print("❌ Ошибка создания запроса")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    defer {
                        self?.task = nil
                        self?.lastUsername = nil
                    }
                    
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        print("Запрос отменён")
                        completion(.failure(ProfileImageServiceError.invalidRequest))
                        return
                    }
                    
                    if let error = error {
                        print("❌ Сетевая ошибка: \(error)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        print("❌ Пустой ответ")
                        completion(.failure(ProfileImageServiceError.invalidRequest))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let bodyAfterDecoding = try decoder.decode(UserResult.self, from: data)
                        guard let avatarURL = bodyAfterDecoding.profileImage?.small else { return }
                        self?.avatarURL = avatarURL
                        completion(.success(avatarURL))
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": avatarURL])
                    } catch {
                        print("❌ Ошибка декодирования пользовательской аватарки: \(error)")
                        completion(.failure(error))
                    }
                }
            }
            self.task = task
            task.resume()
            
    }
    
    private func makeRequestForGettingUserImage(userName: String) -> URLRequest? {
        var components = URLComponents()
        components.path = "/users/\(userName)"
        
        guard let baseURL = URL(string: "https://api.unsplash.com"), let url = components.url(relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(String(describing: storage.token))", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
}
