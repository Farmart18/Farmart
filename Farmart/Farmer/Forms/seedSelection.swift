//
//  seedSelection.swift
//  Farmart
//
//  Created by Anubhav Dubey on 12/07/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct SeedSelection: View {
    @Binding var details: [String: AnyCodable]
    @StateObject private var viewModel = SuggestionViewModel(category: "seeds")

    // Common manure application methods
    let seedCategories = [
            "Breeder",
            "Foundation",
            "Certified",
            "Farm Saved",
            "Open-Pollinated",
            "Hybrid",
            "Heirloom",
            "Raw",
            "Treated",
            "Coated",
            "Large",
            "Small",
            "Vegetable",
            "Cereal",
            "Oil",
            "Pulse",
            "Fodder",
            "Sexual",
            "Asexual"
        ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Type with suggestions
            Picker("Seed Type", selection: Binding(
                get: { stringValue(details["type"]) },
                set: { details["type"] = AnyCodable($0) }
            )) {
                ForEach(seedCategories, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)
            
            // seeds Name
            TextField("Seed Name", text: Binding(
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

            
        }
//        .padding()
    }
}
