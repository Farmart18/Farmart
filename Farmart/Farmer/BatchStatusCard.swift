//
//  BatchStatusCard.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import SwiftUICore

struct BatchStatusCard: View {
    let batch: CropBatch
    let activities: [CropActivity]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(batch.cropType)
                    .font(.headline)
                if batch.isFinalized {
                    Text("Finalized").font(.caption).foregroundColor(.green)
                }
            }
            Text("Variety: \(batch.variety)")
            Text("Sowing: \(batch.sowingDate.formatted(date: .abbreviated, time: .omitted))")
            Text("Activities: \(activities.count)")
            if let last = activities.last {
                Text("Last: \(last.stage.rawValue.capitalized) on \(last.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
            }
        }
        .padding(8)
//        .background(Color.skyBlue)
        .cornerRadius(8)
    }
} 
