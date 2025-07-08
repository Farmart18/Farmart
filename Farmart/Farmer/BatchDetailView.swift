//
//  BatchDetailView.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//
import SwiftUI
import Foundation

struct BatchDetailView: View {
    let batch: CropBatch
    @ObservedObject var store: BatchStore
    @State private var showStagePicker = false
    @State private var selectedStage: CropStage? = nil
    @State private var showFinalizeAlert = false

    var activities: [CropActivity] { store.activities(for: batch) }
    
    // Helper function to sort details
    func sortedDetails(for activity: CropActivity) -> [(key: String, value: AnyCodable)] {
        activity.details.sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section(header: Text("Batch Info")) {
                    Text("Crop: \(batch.cropType)")
                    Text("Variety: \(batch.variety)")
                    Text("Sowing: \(batch.sowingDate.formatted(date: .abbreviated, time: .omitted))")
                    if let notes = batch.notes { Text("Notes: \(notes)") }
                    if batch.isFinalized, let hash = batch.blockchainHash {
                        Text("Blockchain Hash: \(hash)").font(.caption).foregroundColor(.green)
                    }
                }
                Section(header: Text("Activities / Stages")) {
                    if activities.isEmpty {
                        Text("No activities logged yet.").foregroundColor(.secondary)
                    } else {
                        ForEach(activities) { activity in
                            VStack(alignment: .leading) {
                                Text(activity.stage.rawValue.capitalized).bold()
                                Text("Date: \(activity.date.formatted(date: .abbreviated, time: .omitted))")
                                ActivityDetailsView(details: sortedDetails(for: activity))
                                if let images = activity.images, !images.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(images, id: \.self) { data in
                                                if let uiImage = UIImage(data: data) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 60, height: 60)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            HStack {
                Button("Add Activity/Stage") { showStagePicker = true }
                    .buttonStyle(.borderedProminent)
                if !batch.isFinalized {
                    Button("Finalize Batch") { showFinalizeAlert = true }
                        .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle(batch.cropType)
        .sheet(isPresented: $showStagePicker) {
            StagePickerSheet { stage in
                selectedStage = stage
            }
        }
        .sheet(item: $selectedStage) { stage in
            CropActivityForm(cropId: batch.id, stage: stage) { activity in
                Task{
                    await store.addActivity(activity)
                }
            }
        }
        .alert("Finalize Batch", isPresented: $showFinalizeAlert) {
            Button("Finalize", role: .destructive) {
                // TODO: Implement finalizeBatch logic with Supabase if needed
                // let hash = UUID().uuidString.prefix(12)
                // store.finalizeBatch(batch, blockchainHash: String(hash))
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to finalize this batch? This will add it to the blockchain and prevent further edits.")
        }
        .onAppear {
            Task {
                await store.loadActivities(for: batch.id)
            }
        }
    }
}

struct ActivityDetailsView: View {
    let details: [(key: String, value: AnyCodable)]
    var body: some View {
        ForEach(details, id: \.key) { detail in
            Text("\(detail.key.capitalized): \(detail.value.value)").font(.caption)
        }
    }
}

struct StagePickerSheet: View {
    var onPick: (CropStage) -> Void
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            List(CropStage.allCases) { stage in
                Button(stage.rawValue.capitalized) {
                    onPick(stage)
                    dismiss()
                }
            }
            .navigationTitle("Pick Stage")
        }
    }
}

