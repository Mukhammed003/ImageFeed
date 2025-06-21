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
                if let data = data, let response = response, let responseCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= responseCode {
                        fulfillCompletionOnTheMainThread(.success(data))
                    } else {
                        fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(responseCode)))
                    }
                } else if let error = error {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                }
            })
            
            return task
        }
}
