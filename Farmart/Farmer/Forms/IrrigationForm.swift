//
//  IrrigationForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct IrrigationForm: View {
    @Binding var details: [String: AnyCodable]

    // Common irrigation methods
    let irrigationMethods = [
        "Surface Irrigation",
        "Drip Irrigation",
        "Sprinkler Irrigation",
        "Subsurface Irrigation",
        "Center Pivot Irrigation",
        "Lateral Move Irrigation",
        "Manual Irrigation",
        "Flood Irrigation"
    ]

    private func binding(for key: String) -> Binding<String> {
        Binding<String>(
            get: { stringValue(details[key]) },
            set: { details[key] = AnyCodable($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Irrigation method picker
            Picker("Irrigation Method", selection: binding(for: "method")) {
                ForEach(irrigationMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)

            // Duration input
            TextField("Duration (hrs)", text: binding(for: "duration"))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            // Water source input
            TextField("Water Source", text: binding(for: "waterSource"))
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}
