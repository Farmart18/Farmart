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
    @Published var activities: [CropActivity] = []
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
                self.activities = fetched
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
        activities.filter { $0.batchId == batch.id }
    }
    
    // Optionally, add methods for finalizeBatch, deleteBatch, etc., using BatchManager
}

