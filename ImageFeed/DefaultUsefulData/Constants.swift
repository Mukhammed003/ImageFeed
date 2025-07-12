//
//  Constants.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 07.06.2025.
//

import Foundation

enum Constants {
    static let accessKey = "3m3RiUllDqglEAt9BKj-FXSHsm_7KS8nyhdYXwnnaCE"
    static let secretKey = "scoVoZ8aNesEDOVZEjryt_1WnhXboDNqyPaPSQbo9A4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
