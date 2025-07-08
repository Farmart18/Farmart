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

    var body: some View {
        TextField("Method", text: Binding(
            get: { stringValue(details["method"]) },
            set: { details["method"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Duration (hrs)", text: Binding(
            get: { stringValue(details["duration"]) },
            set: { details["duration"] = AnyCodable($0) }
        )).disabled(false)
        TextField("Water Source", text: Binding(
            get: { stringValue(details["waterSource"]) },
            set: { details["waterSource"] = AnyCodable($0) }
        )).disabled(false)
    }
}
