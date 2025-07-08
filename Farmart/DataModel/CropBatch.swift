//
//  CropBatch.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//
import Foundation

// MARK: - CropStage Enum

enum CropStage: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case landPreparation
    case fertilizer
    case manure
    case seedSelection
    case seedTreatment
    case seedSowing
    case irrigation
    case pesticide
    case harvest
}

// MARK: - AnyCodable for flexible details

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Bool.self) { value = v }
        else if let v = try? container.decode(Int.self) { value = v }
        else if let v = try? container.decode(Double.self) { value = v }
        else if let v = try? container.decode(String.self) { value = v }
        else if let v = try? container.decode([String: AnyCodable].self) { value = v }
        else if let v = try? container.decode([AnyCodable].self) { value = v }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON type") }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let v as Bool: try container.encode(v)
        case let v as Int: try container.encode(v)
        case let v as Double: try container.encode(v)
        case let v as String: try container.encode(v)
        case let v as [String: AnyCodable]: try container.encode(v)
        case let v as [AnyCodable]: try container.encode(v)
        default:
            throw EncodingError.invalidValue(value, .init(codingPath: container.codingPath, debugDescription: "Unsupported type"))
        }
    }
}


// MARK: - CropActivity Model

struct CropActivity: Identifiable, Codable {
    let id: UUID
    var batchId: UUID
    var stage: CropStage
    var date: Date
    var details: [String: AnyCodable]
    var images: [String]  // Supabase stores this in jsonb[]
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case batchId = "batch_id"
        case stage
        case date
        case details
        case images
        case createdAt = "created_at"
    }
}


// MARK: - CropBatch Model

struct CropBatch: Identifiable, Codable {
    let id: UUID
    var cropType: String
    var variety: String
    var sowingDate: Date
    var notes: String?
    var isFinalized: Bool
    var blockchainHash: String?
    var farmerId: UUID
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case cropType = "crop_type"
        case variety
        case sowingDate = "sowing_date"
        case notes
        case isFinalized = "is_finalized"
        case blockchainHash = "blockchain_hash"
        case farmerId = "farmer_id"
        case createdAt = "created_at"
    }
}
