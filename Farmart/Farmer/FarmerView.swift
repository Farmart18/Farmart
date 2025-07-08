import SwiftUI

struct FarmerView: View {
    @StateObject private var store = BatchStore()
    @State private var showAddBatch = false
    @State private var selectedBatch: CropBatch?
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationView {
            List {
                ForEach(store.batches) { batch in
                    let activities = store.activities(for: batch)
                    Button(action: { selectedBatch = batch }) {
                        BatchStatusCard(batch: batch, activities: activities)
                    }
                }
            }
            .navigationTitle("Farmart")
            .toolbar {
                Button("Add") { showAddBatch = true }
            }
            .sheet(isPresented: $showAddBatch) {
                AddBatchView(store: store)
            }
            .sheet(item: $selectedBatch) { batch in
                BatchDetailView(batch: batch, store: store)
            }
            .task {
                print("Current farmerId:", authManager.currentFarmerId as Any)

                if let farmerId = authManager.currentFarmerId {
                    do {
                        try await store.loadBatches(for: farmerId)
                    } catch {
                        print("Failed to load batches:", error)
                    }
                }
            }

        }
    }
}

struct FarmerView_Previews: PreviewProvider {
    static var previews: some View {
        FarmerView()
    }
} 
