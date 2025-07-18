# Farmart

Farmart is an iOS application that brings traceability and transparency to agricultural products. It enables farmers to record and manage crop batches and their activities, while allowing consumers to scan QR codes on products to verify their origin and activity history. The app uses Supabase for backend services, Google Sign-In for authentication, and blockchain hashing for data integrity.

---

## Features

### For Farmers
- **Authentication:** Sign in with Google.
- **Batch Management:** Add, view, and manage crop batches.
- **Activity Logging:** Record detailed crop activities (land preparation, sowing, irrigation, fertilization, harvesting, etc.) for each batch.
- **Blockchain Hashing:** Each batch’s data and activities are hashed and stored for tamper-proof verification.
- **QR Code Generation:** Generate QR codes for each batch for consumer verification.

### For Consumers
- **QR Code Scanning:** Scan product QR codes to view batch details and activity history.
- **Batch Verification:** Verify the authenticity and integrity of product data using blockchain hashes.

---

## Project Structure

- `Farmer/`: Views and forms for farmer operations (batch management, activity logging).
- `Consumer/`: Views for consumers to scan and verify product batches.
- `BlockChain/`: Blockchain hashing and verification logic.
- `QR/`: QR code generation and scanning utilities.
- `HelperFuncitons/`: Authentication, batch management, color themes, and utility functions.
- `dataController/`: Data storage and management for batches and activities.
- `DataModel/`: Data models for farmers, batches, and activities.
- `Onboarding/`: Onboarding and role selection (farmer or consumer).

---

## Getting Started

### Prerequisites

- Xcode 14 or later
- Swift 5.7+
- CocoaPods or Swift Package Manager (for dependencies)
- Supabase account and project (for backend)
- Google Cloud project (for Google Sign-In)

### Installation

1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd Farmart
   ```

2. **Install dependencies:**
   - If using CocoaPods:
     ```sh
     pod install
     ```
   - If using Swift Package Manager, open the project in Xcode and resolve packages.

3. **Configure Supabase:**
   - Update `HelperFuncitons/AuthManager.swift` with your Supabase URL and anon key.

4. **Configure Google Sign-In:**
   - Add your `GoogleService-Info.plist` to the project.
   - Update Info.plist with your Google client ID.

5. **Build and run the app in Xcode.**

---

## Usage

- **On launch**, users choose to continue as a Farmer or Consumer.
- **Farmers** can log in, add batches, record activities, and generate QR codes.
- **Consumers** can scan QR codes to view and verify product information.

---

## Technologies Used

- **SwiftUI**: UI framework
- **Supabase**: Backend (auth, database, storage)
- **Google Sign-In**: Authentication
- **AVFoundation**: Camera and QR code scanning
- **CryptoKit**: Blockchain hashing

---

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/YourFeature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/YourFeature`).
5. Create a new Pull Request.

---

## Acknowledgements

- Supabase for backend services
- Google for authentication
- Apple for SwiftUI and AVFoundation 
