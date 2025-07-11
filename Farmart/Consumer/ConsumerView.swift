import SwiftUI
import AVFoundation

struct ConsumerView: View {
    @State private var isScanning = true
    @State private var scannedBatch: CropBatch?
    @State private var scannedActivities: [CropActivity] = []
    @State private var torchOn = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen camera view when scanning
                if isScanning {
                    QRScannerView(
                        torchOn: $torchOn,
                        onQRCodeScanned: handleScannedCode
                    )
                    .edgesIgnoringSafeArea(.all)
                    .overlay(scanningOverlay)
                }
                
                // Scanned product info
                if let batch = scannedBatch {
                    BatchInfoCard(
                        batch: batch,
                        activities: scannedActivities,
                        onRescan: {
                            resetScanner()
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Scan Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isScanning {
                        Button {
                            torchOn.toggle()
                        } label: {
                            Image(systemName: torchOn ? "bolt.fill" : "bolt")
                        }
                    }
                }
            }
            .alert("Scan Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var scanningOverlay: some View {
        ZStack {
            // Semi-transparent border
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue.opacity(0.5), lineWidth: 4)
                .frame(width: 250, height: 250)
            
            // Guidance text
            VStack {
                Spacer()
                Text("Align QR code within frame")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 50)
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        guard let url = URL(string: code),
              let batchId = url.pathComponents.last else {
            showError(message: "Invalid QR code format")
            return
        }
        
        Task {
            do {
                let batch = try await BatchManager.shared.fetchBatchForVerification(batchId: batchId)
                let activities = (try? await BatchManager.shared.fetchActivities(for: batch.id)) ?? []
                
                await MainActor.run {
                    withAnimation {
                        scannedBatch = batch
                        scannedActivities = activities
                        isScanning = false
                    }
                }
            } catch {
                showError(message: "Product not found: \(error.localizedDescription)")
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func resetScanner() {
        withAnimation {
            scannedBatch = nil
            scannedActivities = []
            isScanning = true
        }
    }
}

// MARK: - Preview
struct ConsumerScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ConsumerView()
    }
}
