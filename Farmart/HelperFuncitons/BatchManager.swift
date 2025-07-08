import Foundation
import Supabase

class BatchManager {
    static let shared = BatchManager()
    private let client = AuthManager.shared.client
    
    private init() {}
    
    // Insert a new batch
    func insertBatch(_ batch: CropBatch) async throws {
        let _ = try await client.database
            .from("batch")
            .insert(batch)
            .execute()
    }
    
    // Fetch all batches for a farmer
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
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let batches = try decoder.decode([CropBatch].self, from: data)
            return batches
        } catch {
            print("Decoding error:", error)
            print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
            return []
        }
        
        return []
    }
    
    // Insert a new activity
    func insertActivity(_ activity: CropActivity) async throws {
        let _ = try await client.database
            .from("activity")
            .insert(activity)
            .execute()
    }
    
    // Fetch activities for a batch
    func fetchActivities(for batchId: UUID) async throws -> [CropActivity] {
        let response = try await client.database
            .from("activity")
            .select()
            .eq("batch_id", value: batchId.uuidString)
            .order("date", ascending: true)
            .execute()
        guard let activities = response.value as? [CropActivity] else {
            return []
        }
        return activities
    }
    
    // Fetch batches with activities (join)
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
} 
