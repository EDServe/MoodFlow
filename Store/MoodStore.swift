import Foundation
import Combine

final class MoodStore: ObservableObject {
    @Published var entries: [MoodEntry] = []

    private let saveKey = "mood_entries"

    init() { load() }

    func add(mood: Mood, note: String) {
        let entry = MoodEntry(date: Date(), mood: mood, note: note)
        entries.insert(entry, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    // Returns the last 14 days as (date, avgScore) for charting
    var last14DaysScores: [(date: Date, score: Double)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<14).compactMap { offset -> (Date, Double)? in
            guard let day = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            let dayEntries = entries.filter { $0.date >= day && $0.date < next }
            guard !dayEntries.isEmpty else { return nil }
            let avg = dayEntries.map(\.mood.score).reduce(0, +) / Double(dayEntries.count)
            return (day, avg)
        }.reversed()
    }

    var moodCounts: [Mood: Int] {
        Dictionary(grouping: entries, by: \.mood).mapValues(\.count)
    }

    // MARK: – Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data)
        else { return }
        entries = decoded
    }
}
