//
//  BatchStore.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//
import Foundation
import Combine
import UIKit

class BatchStore: ObservableObject {
    @Published var batches: [CropBatch] = []
    @Published var activitiesByBatch: [UUID: [CropActivity]] = [:]
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Fetch all batches for a farmer
    @MainActor
    func loadBatches(for farmerId: UUID) async {
        await MainActor.run { self.isLoading = true }
        do {
            print("Fetching batches for farmerId:", farmerId)
            let fetched = try await BatchManager.shared.fetchBatches(for: farmerId)
            print("Fetched batches:", fetched)
            await MainActor.run {
                self.batches = fetched
                self.isLoading = false
            }
            // Load activities for all batches
            for batch in fetched {
                Task {
                    await self.loadActivities(for: batch.id)
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    // Add a new batch
    @MainActor
    func addBatch(_ batch: CropBatch) async {
        await MainActor.run { self.isLoading = true }
        do {
            try await BatchManager.shared.insertBatch(batch)
            // Optionally reload batches
            await loadBatches(for: batch.farmerId)
            await MainActor.run { self.isLoading = false }
        } catch {
            await MainActor.run {
                self.error = error
                print("Failed to add batch:", error)
                self.isLoading = false
            }
        }
    }
    
    // Fetch activities for a batch
    @MainActor
    func loadActivities(for batchId: UUID) async {
        await MainActor.run { self.isLoading = true }
        do {
            let fetched = try await BatchManager.shared.fetchActivities(for: batchId)
            await MainActor.run {
                self.activitiesByBatch[batchId] = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    // Add a new activity
    @MainActor
    func addActivityWithImages(_ activity: CropActivity, images: [UIImage]) async {
        await MainActor.run { self.isLoading = true }

        do {
            // Upload images
            let uploadedURLs: [String] = try await withThrowingTaskGroup(of: String.self) { group in
                for image in images {
                    let fileName = UUID().uuidString
                    group.addTask {
                        return try await BatchManager.shared.uploadImageToSupabase(image: image, fileName: fileName)
                    }
                }

                return try await group.reduce(into: [String]()) { $0.append($1) }
            }

            // Insert activity with uploaded image URLs
            var newActivity = activity
            newActivity.images = uploadedURLs

            try await BatchManager.shared.insertActivity(newActivity)
            await loadActivities(for: newActivity.batchId)
            await MainActor.run { self.isLoading = false }

        } catch {
            await MainActor.run {
                self.error = error
                print("Failed to add activity with images:", error)
                self.isLoading = false
            }
        }
    }

    
    // Get activities for a batch from the local cache
    func activities(for batch: CropBatch) -> [CropActivity] {
        activitiesByBatch[batch.id] ?? []
    }
    
    // Optionally, add methods for finalizeBatch, deleteBatch, etc., using BatchManager
}


extension BatchStore {
    @MainActor
    func finalizeBatch(_ batch: CropBatch) async {
        print("Finalize function started") // Add this
        await MainActor.run { self.isLoading = true }
        do {
            print("Getting activities") // Add this
            let activities = activitiesByBatch[batch.id] ?? []
            print("Activities count:", activities.count) // Add this
            
            let hash = BlockchainService.shared.generateBlockchainHash(
                for: batch,
                activities: activities
            )
            print("Generated hash:", hash) // Add this
            
            // Create updated batch object
            var finalizedBatch = batch
            finalizedBatch.isFinalized = true
            finalizedBatch.blockchainHash = hash
            
            print("Updating batch") // Add this
            try await BatchManager.shared.updateBatch(finalizedBatch)
            print("Batch updated successfully") // Add this
            
            // Refresh data
            await loadBatches(for: batch.farmerId)
            
        } catch {
            print("Finalization error:", error) // Add this
            await MainActor.run {
                self.error = error
                print("Finalization failed:", error.localizedDescription)
            }
        }
        await MainActor.run { self.isLoading = false }
        print("Finalize function completed") // Add this
    }
}

