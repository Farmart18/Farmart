//
//  AddBatchView.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//
import SwiftUI

struct AddBatchView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: BatchStore
    @EnvironmentObject var authManager: AuthManager

    @State private var cropType = ""
    @State private var variety = ""
    @State private var sowingDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Crop Type", text: $cropType)
                TextField("Variety", text: $variety)
                DatePicker("Sowing Date", selection: $sowingDate, displayedComponents: .date)
                TextField("Notes (optional)", text: $notes)
            }
            .navigationTitle("Add Batch")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let farmerId = authManager.currentFarmerId else {
                            print("Error: No current farmer ID available.")
                            return
                        }
                        let batch = CropBatch(
                            id: UUID(),
                            cropType: cropType,
                            variety: variety,
                            sowingDate: sowingDate,
                            notes: notes.isEmpty ? nil : notes,
                            isFinalized: false,
                            blockchainHash: nil,
                            farmerId: farmerId,
                            createdAt: Date.now
                        )
                        Task {
                            await store.addBatch(batch)
                            dismiss()
                        }
                    }.disabled(cropType.isEmpty || variety.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

