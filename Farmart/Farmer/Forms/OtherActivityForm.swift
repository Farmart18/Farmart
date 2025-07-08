//
//  OtherActivityForm.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct OtherActivityForm: View {
    @Binding var details: [String: AnyCodable]

    var body: some View {
        TextField("Description", text: Binding(
            get: { stringValue(details["description"]) },
            set: { details["description"] = AnyCodable($0) }
        )).disabled(false)
    }
}
