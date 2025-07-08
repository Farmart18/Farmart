//
//  utils.swift
//  Farmart
//
//  Created by Batch  - 2 on 02/07/25.
//

import SwiftUICore
import UIKit
import SwiftUI


// Helper for rounded corners on specific edges
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView(isLoggedIn: false)
//    }
//} 

func stringValue(_ value: AnyCodable?) -> String {
    if let str = value?.value as? String { return str }
    if let int = value?.value as? Int { return String(int) }
    if let dbl = value?.value as? Double { return String(dbl) }
    if let bool = value?.value as? Bool { return bool ? "true" : "false" }
    return ""
}
