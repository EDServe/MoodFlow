import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: MoodStore

    var body: some View {
        NavigationStack {
            Group {
                if store.entries.isEmpty {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "calendar.badge.plus",
                        description: Text("Start by logging your mood on the Today tab.")
                    )
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            EntryRow(entry: entry)
                        }
                        .onDelete { store.delete(at: $0) }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .toolbar {
                EditButton()
            }
        }
    }
}

struct EntryRow: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.mood.emoji)
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.mood.label)
                    .font(.headline)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Text(entry.dayString)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            MoodScoreBar(score: entry.mood.score)
        }
        .padding(.vertical, 4)
    }
}

struct MoodScoreBar: View {
    let score: Double  // 1–5

    var body: some View {
        VStack(spacing: 2) {
            ForEach((1...5).reversed(), id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Double(i) <= score ? Color.indigo : Color(.systemGray5))
                    .frame(width: 6, height: 8)
            }
        }
    }
}
