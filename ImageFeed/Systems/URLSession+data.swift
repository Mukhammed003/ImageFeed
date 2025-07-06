//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
            let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }}
            
            let task = dataTask(with: request, completionHandler: {data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    let responseCode = httpResponse.statusCode
                    if 200 ..< 300 ~= responseCode {
                        if let data = data {
                            fulfillCompletionOnTheMainThread(.success(data))
                        }
                        else {
                            print("[URLSession.data]: NetworkError - No data in successful response")
                            fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                        }
                    } else {
                        print("[URLSession.data]: NetworkError - HTTP status code \(responseCode)")
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(responseCode)))
                    }
                } else if let error = error {
                    print("[URLSession.data]: NetworkError - URL request error: \(error.localizedDescription)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                } else {
                    print("[URLSession.data]: NetworkError - Unknown URLSession error")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                }
            })
            
            return task
        }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    print("[URLSession.objectTask]: Failure - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("[URLSession.objectTask]: Failure - No data in response")
                    completion(.failure(NSError(
                        domain: "URLSession.objectTask",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No data in response"]
                    )))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print("[URLSession.objectTask]: Decoding error - \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}
