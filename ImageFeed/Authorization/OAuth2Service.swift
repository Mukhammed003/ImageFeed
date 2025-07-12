//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private let tokenStorage = OAuth2TokenStorage.shared
    
    init() {}
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void) {
            assert(Thread.isMainThread)
            if task != nil {
                if lastCode != code {
                    task?.cancel()
                } else {
                    completion(.failure(AuthServiceError.invalidRequest))
                    return
                }
            } else {
                if lastCode == code {
                    completion(.failure(AuthServiceError.invalidRequest))
                    return
                }
            }
            lastCode = code
            
            guard
                let request = makeOAuthTokenRequest(code: code) else {
                print("[OAuth2Service.fetchOAuthToken]: Failure - Request creation error")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                
                guard let self = self else { return }
                
                defer {
                    self.task = nil
                    self.lastCode = nil
                }
                
                switch result {
                case .success(let tokenResponse):
                    let token = tokenResponse.accessToken
                    self.tokenStorage.token = token
                    print("[OAuth2Service.fetchOAuthToken]: Success - token received")
                    completion(.success(token))
                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: Failure - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            self.task = task
            task.resume()
        }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var components = URLComponents()
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let baseURL = URL(string: "https://unsplash.com"),
              let url = components.url(relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        return request
    }
}
