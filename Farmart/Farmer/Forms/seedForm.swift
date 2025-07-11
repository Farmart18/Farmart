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
    @StateObject private var viewModel = SuggestionViewModel(category: "fertilizer")

    let treatmentMethods = [
        "Chemical Treatment",
        "Physical Treatment",
        "Biological Treatment",
        "Priming",
        "Coating and Pelleting",
        "Pelletization",
        "Fungicidal Seed Dressing"
    ]

    // Chemicals for chemical treatment
    let chemicals = [
        "Thiram",
        "Captan",
        "Imidacloprid",
        "Carbendazim",
        "Mancozeb"
    ]

    // Physical methods
    let physicalMethods = [
        "Hot Water Treatment",
        "Dry Heat Treatment",
        "Irradiation"
    ]

    // Biological agents
    let biologicalAgents = [
        "Trichoderma",
        "Rhizobium",
        "Bacillus subtilis"
    ]

    // Priming types
    let primingTypes = [
        "Hydropriming",
        "Osmopriming",
        "Biopriming"
    ]

    @State private var selectedChemical = ""
    @State private var selectedPhysicalMethod = ""
    @State private var selectedBiologicalAgent = ""
    @State private var selectedPrimingType = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
           

            // Treatment Method Picker
            Picker("Treatment Method", selection: Binding(
                get: { stringValue(details["treatmentMethod"]) },
                set: { details["treatmentMethod"] = AnyCodable($0) }
            )) {
                ForEach(treatmentMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)

            // Conditionally show extra input based on selected treatment method
            let treatmentMethod = stringValue(details["treatmentMethod"])

            Group {
                switch treatmentMethod {
                case "Chemical Treatment":
                    Picker("Select Chemical", selection: Binding(
                        get: { stringValue(details["chemical"]) },
                        set: { details["chemical"] = AnyCodable($0) }
                    )) {
                        ForEach(chemicals, id: \.self) { chemical in
                            Text(chemical).tag(chemical)
                        }
                    }
                    .pickerStyle(.menu)

                case "Physical Treatment":
                    Picker("Select Physical Method", selection: Binding(
                        get: { stringValue(details["physicalMethod"]) },
                        set: { details["physicalMethod"] = AnyCodable($0) }
                    )) {
                        ForEach(physicalMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                    .pickerStyle(.menu)

                case "Biological Treatment":
                    Picker("Select Biological Agent", selection: Binding(
                        get: { stringValue(details["biologicalAgent"]) },
                        set: { details["biologicalAgent"] = AnyCodable($0) }
                    )) {
                        ForEach(biologicalAgents, id: \.self) { agent in
                            Text(agent).tag(agent)
                        }
                    }
                    .pickerStyle(.menu)

                case "Priming":
                    Picker("Select Priming Type", selection: Binding(
                        get: { stringValue(details["primingType"]) },
                        set: { details["primingType"] = AnyCodable($0) }
                    )) {
                        ForEach(primingTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)

                default:
                    EmptyView()
                }
            }
            // Steps input
            TextField("Steps (comma separated)", text: Binding(
                get: { stringValue(details["steps"]) },
                set: { details["steps"] = AnyCodable($0) }
            ))
            .textFieldStyle(.roundedBorder)
        }
//        .padding()
    }
}

