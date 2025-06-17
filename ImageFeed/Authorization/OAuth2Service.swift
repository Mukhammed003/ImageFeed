//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let tokenStorage = OAuth2TokenStorage()
    
    init() {}
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void) {
            
            guard let request = makeOAuthTokenRequest(code: code) else {
                    DispatchQueue.main.async {
                        print("❌ Ошибка создания запроса")
                        completion(.failure(NetworkError.urlSessionError))
                    }
                    return
                }

                let task = URLSession.shared.data(for: request) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                            let token = tokenResponse.accessToken
                            self.tokenStorage.token = token
                            print("✅ Токен сохранён: \(token)")
                            DispatchQueue.main.async {
                                completion(.success(token))
                            }
                        } catch {
                            print("❌ Ошибка декодирования токена: \(error)")
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }

                    case .failure(let error):
                        print("❌ Сетевая ошибка или ошибка запроса: \(error)")
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }

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
        request.httpMethod = "POST"
        
        return request
    }
}
