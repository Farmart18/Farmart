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
    
    @State private var showCamera = false

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

                Section {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Capture Photo", systemImage: "camera")
                    }
                }
                .sheet(isPresented: $showCamera) {
                    ImagePicker(sourceType: .camera) { image in
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            images.append(data)
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
            LandPreparationForm(details: $details)
        case .fertilizer:
            FertilizerForm(details: $details)
        case .manure:
            ManureForm(details: $details)
        case .seedSelection:
            SeedSelection(details: $details)
        case .seedTreatment:
            SeedTreatmentForm(details: $details)
        case .seedSowing:
            SeedSowingForm(details: $details)
        case .irrigation:
            IrrigationForm(details: $details)
        case .pesticide:
            PesticideForm(details: $details)
        case .harvest:
            HarvestingForm(details: $details)
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
