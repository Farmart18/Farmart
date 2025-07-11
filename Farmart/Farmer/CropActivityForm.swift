import SwiftUI
import PhotosUI
import Foundation

struct CropActivityForm: View {
    let cropId: UUID
    let stage: CropStage
    var onSave: (CropActivity, [UIImage]) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var details: [String: AnyCodable] = [:]
    @State private var images: [Data] = []
    @State private var date: Date = Date()
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var isUploading = false

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)

                Section(header: Text("Details")) {
                    fieldsForStage
                }

                if !images.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(images, id: \.self) { data in
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }

                PhotosPicker(selection: $photoItems, maxSelectionCount: 3, matching: .images) {
                    Label("Add Photo(s)", systemImage: "photo.on.rectangle")
                }
                .onChange(of: photoItems) { newItems in
                    for item in newItems {
                        Task {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                images.append(data)
                            }
                        }
                    }
                }

                if isUploading {
                    ProgressView("Uploading images...")
                }
            }
            .navigationTitle(stage.rawValue.capitalized)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveActivity()
                        }
                    }
                    .disabled(isUploading)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    var fieldsForStage: some View {
        switch stage {
        case .landPreparation:
            TextField("Tool", text: binding(for: "tool"))
            TextField("Fuel Type", text: binding(for: "fuelType"))
            TextField("Carbon Emission (kg)", text: binding(for: "carbonEmission"))
                .keyboardType(.decimalPad)
            TextField("Method", text: binding(for: "method"))
        case .fertilizer, .manure:
            FertilizerForm(details: $details)
        case .seedSelection:
            Picker("Category", selection: binding(for: "category")) {
                Text("Hybrid").tag("Hybrid")
                Text("Desi").tag("Desi")
            }
            TextField("Name", text: binding(for: "name"))
        case .seedTreatment:
            TextField("Fertilizer", text: binding(for: "fertilizer"))
            TextField("Steps (comma separated)", text: binding(for: "steps"))
        case .seedSowing:
            Picker("Method", selection: binding(for: "method")) {
                Text("Direct").tag("Direct")
                Text("Broadcast").tag("Broadcast")
                Text("Drilling").tag("Drilling")
            }
        case .irrigation:
            Picker("Category", selection: binding(for: "category")) {
                Text("Drip").tag("Drip")
                Text("Sprinkler").tag("Sprinkler")
                Text("Flood").tag("Flood")
            }
            TextField("Duration (hrs)", text: binding(for: "duration"))
            TextField("Water Source", text: binding(for: "waterSource"))
        case .pesticide:
            TextField("Name", text: binding(for: "name"))
        case .harvest:
            Picker("Method", selection: binding(for: "method")) {
                Text("Hand").tag("Hand")
                Text("Machine").tag("Machine")
            }
            TextField("Machine Type", text: binding(for: "machineType"))
        }
    }

    func binding(for key: String) -> Binding<String> {
        Binding<String>(
            get: { (details[key]?.value as? String) ?? "" },
            set: { details[key] = AnyCodable($0) }
        )
    }

    // MARK: - Upload Images and Save Activity
    func saveActivity() async {
        isUploading = true
        var uploadedURLs: [String] = []
        var uiImages: [UIImage] = []

        do {
            for data in images {
                if let image = UIImage(data: data) {
                    let fileName = UUID().uuidString
                    let url = try await BatchManager.shared.uploadImageToSupabase(image: image, fileName: fileName)
                    uploadedURLs.append(url)
                    uiImages.append(image)
                }
            }

            let activity = CropActivity(
                id: UUID(),
                batchId: cropId,
                stage: stage,
                date: date,
                details: details,
                images: uploadedURLs,
                createdAt: Date()
            )

            onSave(activity, uiImages)
            dismiss()

        } catch {
            print("Image upload failed:", error.localizedDescription)
        }

        isUploading = false
    }
}
