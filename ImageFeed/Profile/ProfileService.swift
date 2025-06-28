//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 22.06.2025.
//
import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?
    
    private init() {}
    
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void) {
            assert(Thread.isMainThread)
            if task != nil {
                if lastToken != token {
                    task?.cancel()
                } else {
                    completion(.failure(ProfileServiceError.invalidRequest))
                    return
                }
            } else {
                if lastToken == token {
                    completion(.failure(ProfileServiceError.invalidRequest))
                    return
                }
            }
            lastToken = token
            
            guard
                let request = makeRequestForGettingUserData(bearerToken: token) else {
                print("❌ Ошибка создания запроса")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    defer {
                        self?.task = nil
                        self?.lastToken = nil 
                    }
                    
                    if let error = error as NSError?, error.code == NSURLErrorCancelled {
                        print("Запрос отменён")
                        completion(.failure(ProfileServiceError.invalidRequest))
                        return
                    }
                    
                    if let error = error {
                        print("❌ Сетевая ошибка: \(error)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data else {
                        print("❌ Пустой ответ")
                        completion(.failure(ProfileServiceError.invalidRequest))
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let profileInfo = try decoder.decode(ProfileResult.self, from: data)
                        guard let profile = self?.convertToProile(profileResult: profileInfo) else {
                            print("Ошибка распаковки Profile")
                            return
                        }
                        self?.profile = profile
                        completion(.success(profile))
                    } catch {
                        print("❌ Ошибка декодирования пользовательских данных: \(error)")
                        completion(.failure(error))
                    }
                }
            }
            self.task = task
            task.resume()
        }
    
    private func makeRequestForGettingUserData(bearerToken: String) -> URLRequest? {
        var components = URLComponents()
        components.path = "/me"
        
        guard let baseURL = URL(string: "https://api.unsplash.com"), let url = components.url(relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    private func convertToProile(profileResult: ProfileResult) -> Profile {
        return Profile(
            username: profileResult.username,
            name: "\(profileResult.firstName) \(profileResult.lastName)",
            loginName: "@\(profileResult.username)",
            bio: profileResult.bio ?? "Нет описания")
    }
}

