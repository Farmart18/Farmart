import SwiftUICore
import SwiftUI

struct FertilizerForm: View {
    @Binding var details: [String: AnyCodable]
    @StateObject private var viewModel = FertilizerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Name", text: Binding(
                get: {
                    viewModel.query.isEmpty ? stringValue(details["name"]) : viewModel.query
                },
                set: {
                    viewModel.query = $0
                    details["name"] = AnyCodable($0)
                }
            ))
            .textFieldStyle(.roundedBorder)

            // Dropdown Suggestions
            if !viewModel.suggestions.isEmpty {
                List(viewModel.suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .onTapGesture {
                            viewModel.query = suggestion
                            details["name"] = AnyCodable(suggestion)
                            viewModel.suggestions = []
                        }
                }
                .frame(height: 30)
            }

            TextField("Quantity (kg)", text: Binding(
                get: { stringValue(details["quantityKg"]) },
                set: { details["quantityKg"] = AnyCodable($0) }
            ))
            .textFieldStyle(.roundedBorder)

            TextField("Application Method", text: Binding(
                get: { stringValue(details["method"]) },
                set: { details["method"] = AnyCodable($0) }
            ))
            .textFieldStyle(.roundedBorder)
        }
    }
}
