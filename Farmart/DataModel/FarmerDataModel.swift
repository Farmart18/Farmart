//
//  FarmerDataModel.swift
//  Farmart
//
//  Created by Batch - 2 on 02/07/25.
//

import Foundation

struct Farmer: Identifiable, Codable {
    var id: UUID
    var name: String
    var email: String
    var phone: String?
    var profileImage: URL?
    var createdAt: Date

    // Custom decoding to allow decoding profileImage from String URL
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case profileImage
        case createdAt
    }

    init(id: UUID = UUID(), name: String, email: String, phone: String? = nil, profileImage: URL? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.profileImage = profileImage
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)

        if let profileImageString = try container.decodeIfPresent(String.self, forKey: .profileImage) {
            profileImage = URL(string: profileImageString)
        } else {
            profileImage = nil
        }

        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}
