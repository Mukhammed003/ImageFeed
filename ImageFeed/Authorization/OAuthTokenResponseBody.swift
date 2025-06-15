//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 14.06.2025.
//

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
