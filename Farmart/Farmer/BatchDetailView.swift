//  BatchDetailView.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.

import SwiftUI
import Foundation

struct BatchDetailView: View {
    let batch: CropBatch
    @ObservedObject var store: BatchStore
    @State private var showStagePicker = false
    @State private var selectedStage: CropStage? = nil
    @State private var showFinalizeAlert = false
    @State private var showVerificationAlert = false
    @Environment(\.dismiss) var dismiss


    var activities: [CropActivity] { store.activities(for: batch) }

    // Helper function to sort details
    func sortedDetails(for activity: CropActivity) -> [DetailItem] {
        activity.details.map { DetailItem(key: $0.key, value: $0.value) }.sorted { $0.key < $1.key }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section(header: Text("Batch Info")) {
                    Text("Crop: \(batch.cropType)")
                    Text("Variety: \(batch.variety)")
                    Text("Sowing: \(batch.sowingDate.formatted(date: .abbreviated, time: .omitted))")
                    if let notes = batch.notes { Text("Notes: \(notes)") }
                    if batch.isFinalized {
                        Label("Secured on Blockchain", systemImage: "lock.shield.fill")
                            .foregroundColor(.green)
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
                                let images = activity.images
                                if(!images.isEmpty) {
                                    ActivityImagesView(images: images)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
           
            if !batch.isFinalized {
                HStack {
                   Button("Add Activity/Stage") {
                       showStagePicker = true
                   }
                   .buttonStyle(.borderedProminent)
                   
                   Button("Finalize Batch") {
                       showFinalizeAlert = true
                   }
                   .buttonStyle(.bordered)
               }
               .padding()
            }
            
            
        }
        .navigationTitle("Batch details")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }

        .sheet(isPresented: $showStagePicker) {
            StagePickerSheet { stage in
                selectedStage = stage
            }
        }
        .sheet(item: $selectedStage) { stage in
            CropActivityForm(cropId: batch.id, stage: stage) { activity, uiImages in
                Task {
                    await store.addActivityWithImages(activity, images: uiImages)
                }
            }
        }
        .alert("Finalize Batch", isPresented: $showFinalizeAlert) {
            Button("Finalize", role: .destructive) {
                Task {
                    await store.finalizeBatch(batch)
                }
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

struct DetailItem: Identifiable {
    let id = UUID()
    let key: String
    let value: AnyCodable
}

struct ActivityDetailsView: View {
    let details: [DetailItem]
    var body: some View {
        ForEach(details) { detail in
            Text("\(detail.key.capitalized): \(detail.value.value)").font(.caption)
        }
    }
}

struct ActivityImagesView: View {
    let images: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(images, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .frame(height: 70)
    }
}


struct StagePickerSheet: View {
    var onPick: (CropStage) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(CropStage.allCases, id: \.self) { stage in
                Button(stage.rawValue.capitalized) {
                    onPick(stage)
                    dismiss()
                }
            }
            .navigationTitle("Pick Stage")
        }
    }
}

