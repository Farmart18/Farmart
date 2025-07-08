//
//  ActivityStore.swift
//  Farmart
//
//  Created by Anubhav Dubey on 07/07/25.
//

import Foundation

class ActivityStore: ObservableObject {
    @Published var activities: [CropActivity] = [] {
        didSet { save() }
    }

    private let fileURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("activities.json")
    }()

    init() {
        load()
    }

    func add(_ activity: CropActivity) {
        activities.append(activity)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(activities)
            try data.write(to: fileURL)
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            activities = try JSONDecoder().decode([CropActivity].self, from: data)
        } catch {
            print("Load error: \(error)")
        }
    }

    static func clearAll() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("activities.json")
        try? FileManager.default.removeItem(at: fileURL)
    }
}
