//
//  Structures.swift
//  ImageFeed
//
//  Created by Илья on 19.03.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

struct ProfileResult: Decodable {
    let username: String
    var name: String
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    var loginName: String {
        "@\(username)"
    }
    let bio: String?
}

struct UserResult: Codable {
    let items: [String: String]
    
    private enum CodingKeys: String, CodingKey {
        case items = "profile_image"
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case isLiked = "liked_by_user"
    }
    
    struct UrlsResult: Codable {
        let thumb: String
        let full: String
    }
}
