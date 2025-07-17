//
//  QRCodeGenerator.swift
//  Farmart
//
//  Created by Anshika on 12/07/25.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCodeGenerator {
    static func generate(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .none
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
