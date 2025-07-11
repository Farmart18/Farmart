//
//  SeedSowingForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 11/07/25.
//

import SwiftUI
import SwiftUICore

struct SeedSowingForm: View {
    @Binding var details: [String: AnyCodable]

    // Common seed sowing methods
    let sowingMethods = [
        "Direct",
        "Broadcast",
        "Drilling",
        "Transplanting",
        "Dibbling",
        "Hill Dropping",
        "Seed Balling",
        "Hydroseeding",
        "Strip Sowing"
    ]

    private func binding(for key: String) -> Binding<String> {
        Binding<String>(
            get: { stringValue(details[key]) },
            set: { details[key] = AnyCodable($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Method", selection: binding(for: "method")) {
                ForEach(sowingMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)

            TextField("Steps (comma separated)", text: binding(for: "steps"))
                .textFieldStyle(.roundedBorder)
        }
//        .padding()
    }
}

