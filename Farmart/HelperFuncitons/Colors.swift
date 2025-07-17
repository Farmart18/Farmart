//
//  Colors.swift
//  Farmart
//
//  Created by Batch  - 2 on 02/07/25.
//

import Foundation
import SwiftUI

extension Color {
    static let baseBlue = Color(hex: "2152DA")
    static let ButtonColor = Color(hex: "2152DA")
    static let yellowAccent = Color(hex: "F5C142")
    static let darkBlue = Color(hex: "071C6B")
    static let lightBlue = Color(hex: "56BDF5")
    static let Background = Color(hex: "FFFFFF")
    static let skyBlue = Color(hex: "ABDFF7")
    static let TextColor = Color(hex: "000000")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
