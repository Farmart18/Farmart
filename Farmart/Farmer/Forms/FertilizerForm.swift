import SwiftUICore
import SwiftUI

struct FertilizerForm: View {
    @Binding var details: [String: AnyCodable]
    @StateObject private var viewModel = SuggestionViewModel(category: "fertilizer")

    let applicationMethods = [
        "Broadcasting",
        "Band Placement",
        "Side Dressing",
        "Foliar Application",
        "Fertigation",
        "Deep Placement",
        "Streaking Over Seed",
        "Soil Incorporation"
    ]

    // Helper to get/set quantity as Double safely
    private var quantityBinding: Binding<Double> {
        Binding<Double>(
            get: {
                if let qtyString = details["quantityKg"]?.value as? String,
                   let qty = Double(qtyString) {
                    return qty
                }
                return 0
            },
            set: {
                details["quantityKg"] = AnyCodable(String(format: "%.2f", $0))
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Name field with suggestions
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

            if !viewModel.suggestions.isEmpty {
                List(viewModel.suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .onTapGesture {
                            viewModel.query = suggestion
                            details["name"] = AnyCodable(suggestion)
                            viewModel.suggestions = []
                        }
                }
                .frame(height: 25)
            }

            // Quantity with Stepper + TextField
            HStack {
                Text("Quantity (kg):")

                Spacer()

                // Display quantity as text
                Text(String(format: "%.2f", quantityBinding.wrappedValue))
                    .frame(width: 80, alignment: .trailing)
                    .padding(.trailing, 8)

                // Stepper without label, controls quantityBinding
                Stepper("", value: quantityBinding, in: 0...10000, step: 0.5)
                    .labelsHidden()
            }


            // Application Method Picker
            Picker("Application Method", selection: Binding(
                get: { stringValue(details["method"]) },
                set: { details["method"] = AnyCodable($0) }
            )) {
                ForEach(applicationMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)
        }
//        .padding()
    }
}
