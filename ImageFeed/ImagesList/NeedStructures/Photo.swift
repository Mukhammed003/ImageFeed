//
//  Photo.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 12.07.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
