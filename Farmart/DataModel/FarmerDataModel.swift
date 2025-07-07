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
    //var phone: String?
    var profileImage: URL?
    var createdAt: Date
    
    init(id: UUID, name: String, email: String, profileImage: URL? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImage = profileImage
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
           case id, name, email
           case profileImage = "profile_image"
           case createdAt = "created_at"
       }
}
