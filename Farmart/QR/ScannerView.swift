//
//  ScannerView.swift
//  Farmart
//
//  Created by Anshika on 12/07/25.
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - UIKit Scanner View
class ScannerView: UIView {
    private var captureSession: AVCaptureSession!
    var onQRCodeScanned: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScanner()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScanner()
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            print("Failed to setup camera input")
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else {
            print("Failed to setup metadata output")
            return
        }
        
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                layer.frame = self.bounds
            }
        }
    }
}

extension ScannerView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            captureSession.stopRunning()
            onQRCodeScanned?(stringValue)
        }
    }
}

struct QRScannerView: UIViewRepresentable {
    @Binding var torchOn: Bool
    var onQRCodeScanned: (String) -> Void
    
    func makeUIView(context: Context) -> ScannerView {
        let view = ScannerView()
        view.onQRCodeScanned = onQRCodeScanned
        return view
    }
    
    func updateUIView(_ uiView: ScannerView, context: Context) {
        uiView.toggleTorch(on: torchOn)
    }
}
