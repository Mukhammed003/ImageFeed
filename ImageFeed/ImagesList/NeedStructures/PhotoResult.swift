//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 12.07.2025.
//

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool?
}

struct UrlsResult: Decodable {
    let full: String
    let thumb: String
}
