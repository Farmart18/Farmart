//
//  ActivityListView.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//
import SwiftUI

struct ActivityListView: View {
    @StateObject private var store = ActivityStore()
    @State private var showAdd = false

    var body: some View {
        NavigationView {
            List(store.activities) { activity in
                VStack(alignment: .leading) {
//                    Text(activity.type.rawValue.capitalized)
//                        .font(.headline)
                    Text("Date: \(activity.date.formatted())")
                    Text("Details: \(activity.details.map { "\($0.key): \($0.value.value)" }.joined(separator: ", "))")
                        .font(.caption)
                }
            }
            .navigationTitle("Crop Activities")
            .toolbar {
                Button("Add") { showAdd = true }
                Button("Reset") {
                    ActivityStore.clearAll()
                    store.activities = []
                }
            }
            .sheet(isPresented: $showAdd) {
//                AddActivityView(store: store)
            }
        }
    }
}
