//
//  BatchInfoView.swift
//  Farmart
//
//  Created by Anshika on 12/07/25.
//

import Foundation
import SwiftUI

// MARK: - Product Info Card
struct BatchInfoCard: View {
    let batch: CropBatch
    var activities: [CropActivity]
    var onRescan: () -> Void
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product header
                VStack(alignment: .leading) {
                    Text(batch.cropType)
                        .font(.title.bold())
                    Text(batch.variety)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                // Key details
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(icon: "calendar", label: "Sowing Date", value: batch.sowingDate.formatted(date: .abbreviated, time: .omitted))
                    
                    if let notes = batch.notes {
                        DetailRow(icon: "note.text", label: "Notes", value: notes)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Growing timeline
                Text("Growing Process")
                    .font(.headline)
                
                ForEach(activities) { activity in
                    ActivityTimelineView(activity: activity)
                }
                
                // Rescan button
                Button(action: onRescan) {
                    Label("Scan Another Product", systemImage: "qrcode.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct ActivityTimelineView: View {
    let activity: CropActivity
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.blue)
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(activity.stage.rawValue.capitalized)
                    .font(.subheadline.bold())
                Text(activity.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !activity.images.isEmpty {
                    ActivityImagesView(images: activity.images)
                }
            }
            
            Spacer()
        }
        .padding(.leading, 8)
    }
}
