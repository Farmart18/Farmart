import Foundation
import Supabase
import UIKit

class BatchManager {
    static let shared = BatchManager()
    private let client = AuthManager.shared.client
    
    private init() {}
    
    //MARK: - Insert a new batch
    func insertBatch(_ batch: CropBatch) async throws {
        let _ = try await client.database
            .from("batch")
            .insert(batch)
            .execute()
    }
    
    //MARK: - Fetch all batches for a farmer
    func fetchBatches(for farmerId: UUID) async throws -> [CropBatch] {
        let response = try await client.database
            .from("batch")
            .select()
            .eq("farmer_id", value: farmerId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        let data = response.data
        
        do {
            
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // Setup ISO8601 formatter with fractional seconds
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            // Setup formatter for "yyyy-MM-dd"
            let simpleFormatter = DateFormatter()
            simpleFormatter.dateFormat = "yyyy-MM-dd"
            simpleFormatter.locale = Locale(identifier: "en_US_POSIX")

            // Use custom date decoding strategy
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)

                if let date = isoFormatter.date(from: dateStr) {
                    return date
                } else if let shortDate = simpleFormatter.date(from: dateStr) {
                    return shortDate
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Unrecognized date format: \(dateStr)"
                    )
                }
            }

            
            let batches = try decoder.decode([CropBatch].self, from: data)
            return batches
            
        } catch {
            print("Decoding error:", error)
            print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
            return []
        }
    }

    
    //MARK: -  Insert a new activity
    func insertActivity(_ activity: CropActivity) async throws {
        let _ = try await client.database
            .from("activity")
            .insert(activity)
            .execute()
    }
    
    //MARK: -  Fetch activities for a batch
    func fetchActivities(for batchId: UUID) async throws -> [CropActivity] {
        let response = try await client.database
            .from("activity")
            .select()
            .eq("batch_id", value: batchId.uuidString)
            .order("date", ascending: true)
            .execute()
        
        let data = response.data

        // Configure decoder
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Setup ISO 8601 with fractional seconds
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Fallback for plain date format
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd"
        simpleFormatter.locale = Locale(identifier: "en_US_POSIX")

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            if let isoDate = isoFormatter.date(from: dateStr) {
                return isoDate
            } else if let shortDate = simpleFormatter.date(from: dateStr) {
                return shortDate
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unrecognized date format: \(dateStr)"
                )
            }
        }

        do {
            let activities = try decoder.decode([CropActivity].self, from: data)
            return activities
        } catch {
            print("Decoding error in fetchActivities: \(error)")
            print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
            return []
        }
    }

    
    //MARK: -  Fetch batches with activities (join)
    struct BatchWithActivities: Decodable {
        let id: UUID
        let crop_type: String
        let variety: String
        let sowing_date: Date
        let notes: String?
        let is_finalized: Bool
        let blockchain_hash: String?
        let farmer_id: UUID
        let created_at: Date
        let activity: [CropActivity]
    }
    
    func fetchBatchesWithActivities(for farmerId: UUID) async throws -> [BatchWithActivities] {
        let response = try await client.database
            .from("batch")
            .select("*, activity(*)")
            .eq("farmer_id", value: farmerId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        guard let batches = response.value as? [BatchWithActivities] else {
            return []
        }
        return batches
    }

    
    //MARK: -  Uploads a UIImage to Supabase Storage and returns the public URL string
    func uploadImageToSupabase(image: UIImage, fileName: String, bucket: String = "activity-images") async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"])
        }
        let filePath = "activities/\(fileName).jpg"
        _ = try await client.storage.from(bucket).upload(
            path: filePath,
            file: imageData,
            options: FileOptions(contentType: "image/jpeg", upsert: true)
        )
        // Construct the public URL manually
        let publicURL = "\(AuthManager.shared.getSupabaseURL())/storage/v1/object/public/\(bucket)/\(filePath)"
        return publicURL
    }

    //MARK: -  Updates the images array for an activity in the activity table
    struct ActivityImagesUpdate: Encodable {
        let id: String
        let images: [String]
    }
    
    func updateActivityImages(activityId: UUID, imageURLs: [String]) async throws {
        let updates = ActivityImagesUpdate(id: activityId.uuidString, images: imageURLs)
        _ = try await client.database
            .from("activity")
            .update(updates)
            .eq("id", value: activityId.uuidString)
            .execute()
    }
    
//    func updateBatch(_ batch: CropBatch) async throws {
//        print("Attempting to update batch with ID:", batch.id) // Add this
//        let updates = BatchUpdate(
//            crop_type: batch.cropType,
//            variety: batch.variety,
//            sowing_date: batch.sowingDate,
//            notes: batch.notes,
//            is_finalized: batch.isFinalized,
//            blockchain_hash: batch.blockchainHash
//        )
//        
//        print("Update payload:", updates) // Add this
//        
//        let result = try await client.database
//            .from("batch")
//            .update(updates)
//            .eq("id", value: batch.id.uuidString)
//            .execute()
//        
//        print("Update result:", result) // Add this
//    }
    
    func updateBatch(_ batch: CropBatch) async throws {
        print("Attempting to update batch with ID:", batch.id)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        let updates = BatchUpdate(
            id: batch.id,  // Include the ID
            crop_type: batch.cropType,
            variety: batch.variety,
            sowing_date: batch.sowingDate,
            notes: batch.notes,
            is_finalized: batch.isFinalized,
            blockchain_hash: batch.blockchainHash
        )
        
        // Convert to dictionary to inspect
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(updates)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        print("Update payload as dictionary:", dict ?? "nil")
        
        let result = try await client.database
            .from("batch")
            .update(updates)
            .eq("id", value: batch.id.uuidString)
            .execute()
        
        print("Update result:", result)
        
        // Verify the update by fetching immediately
        let verify = try await client.database
            .from("batch")
            .select()
            .eq("id", value: batch.id.uuidString)
            .single()
            .execute()
        
        print("Verification fetch:", String(data: verify.data, encoding: .utf8) ?? "nil")
    }
}


