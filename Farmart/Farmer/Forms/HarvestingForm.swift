import SwiftUI
import SwiftUICore

struct HarvestingForm: View {
    @Binding var details: [String: AnyCodable]

    let methods = [
        "Manual",
        "Mechanical",
        "Semi-Mechanical",
        "Selective Harvesting",
        "Strip Harvesting",
        "Shaking or Beating",
        "Whole Plant Harvesting",
        "Dredging"
    ]

    let handTools = ["Sickle", "Knife", "Shears", "Clippers"]
    let machines = ["Combine Harvester", "Reaper", "Tractor", "Threshing Machine"]
    let beatingTools = ["Sticks", "Mechanical Shaker"]

    let fuelOptions: [String: [String]] = [
        "Sickle": ["None"],
        "Knife": ["None"],
        "Shears": ["None"],
        "Clippers": ["None"],
        "Combine Harvester": ["Diesel", "Biofuel"],
        "Reaper": ["Diesel", "Petrol"],
        "Tractor": ["Diesel", "CNG", "Electric"],
        "Threshing Machine": ["Diesel", "Electric"],
        "Sticks": ["None"],
        "Mechanical Shaker": ["Diesel", "Electric"]
    ]

    private func binding(for key: String) -> Binding<String> {
        Binding<String>(
            get: { stringValue(details[key]) },
            set: { details[key] = AnyCodable($0) }
        )
    }

    var selectedMethod: String { stringValue(details["method"]) }
    var selectedTool: String { stringValue(details["tool"]) }
    var selectedMachine: String { stringValue(details["machineType"]) }
    var selectedBeatingTool: String { stringValue(details["beatingTool"]) }

    var fuelList: [String] {
        switch selectedMethod {
        case "Manual":
            return fuelOptions[selectedTool] ?? ["None"]
        case "Mechanical", "Semi-Mechanical":
            return fuelOptions[selectedMachine] ?? ["None"]
        case "Shaking or Beating":
            return fuelOptions[selectedBeatingTool] ?? ["None"]
        default:
            return []
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Harvesting Method", selection: binding(for: "method")) {
                ForEach(methods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(.menu)

            Group {
                switch selectedMethod {
                case "Manual":
                    Picker("Tool Used", selection: binding(for: "tool")) {
                        ForEach(handTools, id: \.self) { tool in
                            Text(tool).tag(tool)
                        }
                    }
                    .pickerStyle(.menu)

                    if !fuelList.isEmpty {
                        Picker("Fuel Type", selection: binding(for: "fuelType")) {
                            ForEach(fuelList, id: \.self) { fuel in
                                Text(fuel).tag(fuel)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                case "Mechanical", "Semi-Mechanical":
                    Picker("Machine Type", selection: binding(for: "machineType")) {
                        ForEach(machines, id: \.self) { machine in
                            Text(machine).tag(machine)
                        }
                    }
                    .pickerStyle(.menu)

                    if !fuelList.isEmpty {
                        Picker("Fuel Type", selection: binding(for: "fuelType")) {
                            ForEach(fuelList, id: \.self) { fuel in
                                Text(fuel).tag(fuel)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                case "Shaking or Beating":
                    Picker("Beating Tool", selection: binding(for: "beatingTool")) {
                        ForEach(beatingTools, id: \.self) { tool in
                            Text(tool).tag(tool)
                        }
                    }
                    .pickerStyle(.menu)

                    if !fuelList.isEmpty {
                        Picker("Fuel Type", selection: binding(for: "fuelType")) {
                            ForEach(fuelList, id: \.self) { fuel in
                                Text(fuel).tag(fuel)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                case "Selective Harvesting":
                    TextField("Selected Crop or Part", text: binding(for: "selectedCropPart"))
                        .textFieldStyle(.roundedBorder)

                case "Strip Harvesting":
                    TextField("Strip Width or Description", text: binding(for: "stripDetails"))
                        .textFieldStyle(.roundedBorder)

                case "Whole Plant Harvesting":
                    TextField("Crop Type (e.g. sugarcane)", text: binding(for: "cropType"))
                        .textFieldStyle(.roundedBorder)

                case "Dredging":
                    TextField("Water Depth / Method", text: binding(for: "dredgingDetails"))
                        .textFieldStyle(.roundedBorder)

                default:
                    EmptyView()
                }
            }

            TextField("Notes / Harvest Time", text: binding(for: "notes"))
                .textFieldStyle(.roundedBorder)
        }
//        .padding() 
    }
}
