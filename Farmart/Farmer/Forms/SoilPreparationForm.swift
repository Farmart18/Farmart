//
//  SoilPreparationForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import SwiftUICore
import SwiftUI

struct SoilPreparationForm: View {
    @Binding var details: [String: AnyCodable]

    var body: some View {
        TextField("Preparation Method", text: Binding(
            get: { stringValue(details["method"]) },
            set: { details["method"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Tools Used", text: Binding(
            get: { stringValue(details["tools"]) },
            set: { details["tools"] = AnyCodable($0) }
        )).disabled(false)
    }
}
