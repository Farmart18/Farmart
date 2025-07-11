//
//  BlockchainService.swift
//  Farmart
//
//  Created by Anshika on 12/07/25.
//

import Foundation
import CryptoKit

class BlockchainService {
    static let shared = BlockchainService()
    
    private init() {}
    
    func generateBlockchainHash(for batch: CropBatch, activities: [CropActivity]) -> String {
        // 1. Prepare the data structure
        let batchData: [String: Any] = [
            "id": batch.id.uuidString,
            "cropType": batch.cropType,
            "variety": batch.variety,
            "sowingDate": batch.sowingDate.timeIntervalSince1970,
            "activities": activities.map { activity in
                [
                    "stage": activity.stage.rawValue,
                    "date": activity.date.timeIntervalSince1970,
                    "details": activity.details.mapValues { $0.value }
                ]
            }
        ]
        
        // 2. Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: batchData, options: []) else {
            return "invalid_data"
        }
        
        // 3. Calculate SHA256 hash
        let hash = SHA256.hash(data: jsonData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func verifyBatch(batch: CropBatch, activities: [CropActivity]) -> Bool {
        guard let storedHash = batch.blockchainHash else { return false }
        let calculatedHash = generateBlockchainHash(for: batch, activities: activities)
        return storedHash == calculatedHash
    }
}
