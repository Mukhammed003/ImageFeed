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
                print("[ProfileService.fetchProfile]: Failure - Request creation error")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
                
                guard let self = self else { return }
                
                defer {
                    self.task = nil
                    self.lastToken = nil
                }
                
                switch result {
                case .success(let profileInfo):
                    let profile = self.convertToProfile(profileResult: profileInfo)
                    self.profile = profile
                    print("[ProfileService.fetchProfile]: Success - Profile info received")
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: Failure - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            self.task = task
            task.resume()
        }
    
    func clearProfile() {
        self.profile = nil
    }
    
    private func makeRequestForGettingUserData(bearerToken: String) -> URLRequest? {
        var components = URLComponents()
        components.path = "/me"
        
        guard let baseURL = URL(string: "https://api.unsplash.com"), let url = components.url(relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        
        return request
    }
    
    private func convertToProfile(profileResult: ProfileResult) -> Profile {
        return Profile(
            username: profileResult.username,
            name: "\(profileResult.firstName) \(profileResult.lastName)",
            loginName: "@\(profileResult.username)",
            bio: profileResult.bio ?? "Нет описания")
    }
}

