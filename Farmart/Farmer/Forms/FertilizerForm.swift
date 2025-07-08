//
//  FertilizerForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct FertilizerForm: View {
    @Binding var details: [String: AnyCodable]

    var body: some View {
        TextField("Fertilizer Name", text: Binding(
            get: { stringValue(details["name"]) },
            set: { details["name"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Quantity (kg)", text: Binding(
            get: { stringValue(details["quantityKg"]) },
            set: { details["quantityKg"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Application Method", text: Binding(
            get: { stringValue(details["method"]) },
            set: { details["method"] = AnyCodable($0) }
        )).disabled(false)
    }
}
