//
//  seedForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 11/07/25.
//

import SwiftUI
import SwiftUICore

struct SeedTreatmentForm: View {
    @Binding var details: [String: AnyCodable]
    @StateObject private var viewModel = SuggestionViewModel(category: "fertilizer") // you can change category if needed

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Fertilizer Input with Suggestions
            TextField("Fertilizer", text: Binding(
                get: {
                    viewModel.query.isEmpty ? stringValue(details["fertilizer"]) : viewModel.query
                },
                set: {
                    viewModel.query = $0
                    details["fertilizer"] = AnyCodable($0)
                }
            ))
            .textFieldStyle(.roundedBorder)

            // Dropdown Suggestion List
            if !viewModel.suggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.suggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                                .onTapGesture {
                                    viewModel.query = suggestion
                                    details["fertilizer"] = AnyCodable(suggestion)
                                    viewModel.suggestions = []
                                }
                        }
                    }
                }
                .frame(maxHeight: 100)
            }

            // Steps input
            TextField("Steps (comma separated)", text: Binding(
                get: { stringValue(details["steps"]) },
                set: { details["steps"] = AnyCodable($0) }
            ))
            .textFieldStyle(.roundedBorder)
        }
    }
}

