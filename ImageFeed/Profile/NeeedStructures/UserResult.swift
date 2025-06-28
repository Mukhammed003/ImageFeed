//
//  UserResult.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 22.06.2025.
//

struct UserResult: Codable {
    let profileImage: ProfileImage?
}

struct ProfileImage: Codable {
    let small: String?
}
