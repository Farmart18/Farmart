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
    init(_ value: Any) { self.value = value }
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let val = try? container.decode(Bool.self) { value = val }
        else if let val = try? container.decode(Int.self) { value = val }
        else if let val = try? container.decode(Double.self) { value = val }
        else if let val = try? container.decode(String.self) { value = val }
        else if let val = try? container.decode([String: AnyCodable].self) { value = val }
        else if let val = try? container.decode([AnyCodable].self) { value = val }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type") }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let val as Bool: try container.encode(val)
        case let val as Int: try container.encode(val)
        case let val as Double: try container.encode(val)
        case let val as String: try container.encode(val)
        case let val as [String: AnyCodable]: try container.encode(val)
        case let val as [AnyCodable]: try container.encode(val)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported type")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

// MARK: - CropActivity Model

struct CropActivity: Identifiable, Codable {
    let id: UUID
    let cropId: UUID
    let stage: CropStage
    let date: Date
    var details: [String: AnyCodable]
    var images: [Data]? // Optional: store image data locally
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case cropId = "batch_id"
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
