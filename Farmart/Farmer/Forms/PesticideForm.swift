//
//  PesticideForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct PesticideForm: View {
    @Binding var details: [String: AnyCodable]

    var body: some View {
        TextField("Pesticide Name", text: Binding(
            get: { stringValue(details["name"]) },
            set: { details["name"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Dosage (L/acre)", text: Binding(
            get: { stringValue(details["dosage"]) },
            set: { details["dosage"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Purpose", text: Binding(
            get: { stringValue(details["purpose"]) },
            set: { details["purpose"] = AnyCodable($0) }
        )).disabled(false)
    }
}
