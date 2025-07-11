//
//  landpreperation.swift
//  Farmart
//
//  Created by Anubhav Dubey on 11/07/25.
//

import SwiftUI
import SwiftUICore

struct LandPreparationForm: View {
    @Binding var details: [String: AnyCodable]

    private func binding(for key: String) -> Binding<String> {
        Binding<String>(
            get: { stringValue(details[key]) },
            set: { details[key] = AnyCodable($0) }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // MARK: Tool Picker
            Picker("Tool Used", selection: binding(for: "tool")) {
                ForEach(Array(toolFuelMapping.keys), id: \.self) { tool in
                    Text(tool).tag(tool)
                }
            }
            .pickerStyle(.menu)

            // MARK: Fuel Type Picker (depends on Tool)
            let selectedTool = stringValue(details["tool"])
            if let fuels = toolFuelMapping[selectedTool] {
                Picker("Fuel Type", selection: binding(for: "fuelType")) {
                    ForEach(fuels, id: \.self) { fuel in
                        Text(fuel).tag(fuel)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text("Select a tool to choose fuel type.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }

            // MARK: Method Picker
            Picker("Preparation Method", selection: binding(for: "method")) {
                ForEach(landPreparationMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }
}

// MARK: - Tool to Fuel Mapping
let toolFuelMapping: [String: [String]] = [
    "Tractor": ["Diesel", "Electric", "Petrol"],
    "Power Tiller": ["Diesel", "Petrol"],
    "Manual Plough": ["None"],
    "Bullock-Drawn Plough": ["Animal Power"],
    "Rotavator": ["Diesel", "Electric"],
    "Laser Leveler": ["Diesel"],
    "Cultivator": ["Diesel", "Manual"],
    "Harrow": ["Manual", "Tractor Powered"]
]

// MARK: - Land Preparation Methods
let landPreparationMethods: [String] = [
    "Ploughing",
    "Harrowing",
    "Levelling",
    "Manuring",
    "Mulching",
    "Ridging & Furrowing",
    "Chiseling",
    "Cover Cropping",
    "Weed Control"
]


