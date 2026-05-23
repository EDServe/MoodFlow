import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var store: MoodStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if store.entries.isEmpty {
                        ContentUnavailableView(
                            "No data yet",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Log a few moods to see your trends here.")
                        )
                        .padding(.top, 60)
                    } else {
                        TrendCard(data: store.last14DaysScores)
                        DistributionCard(counts: store.moodCounts)
                        StatsCard(entries: store.entries)
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
        }
    }
}

// MARK: – Trend chart (Swift Charts)

struct TrendCard: View {
    let data: [(date: Date, score: Double)]

    var body: some View {
        CardContainer(title: "14-Day Trend", icon: "chart.line.uptrend.xyaxis") {
            if data.isEmpty {
                Text("Not enough data yet")
                    .foregroundStyle(.secondary)
                    .frame(height: 140)
            } else {
                Chart(data, id: \.date) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Score", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.indigo)

                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Score", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(colors: [.indigo.opacity(0.3), .clear],
                                       startPoint: .top, endPoint: .bottom)
                    )

                    PointMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Score", point.score)
                    )
                    .foregroundStyle(Color.indigo)
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text(moodLabel(v)).font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 160)
            }
        }
    }

    private func moodLabel(_ score: Int) -> String {
        switch score {
        case 1: return "Awful"
        case 2: return "Bad"
        case 3: return "Meh"
        case 4: return "Good"
        case 5: return "Rad"
        default: return ""
        }
    }
}

// MARK: – Distribution bar chart

struct DistributionCard: View {
    let counts: [Mood: Int]

    var body: some View {
        CardContainer(title: "Mood Distribution", icon: "chart.bar.fill") {
            Chart(Mood.allCases, id: \.self) { mood in
                BarMark(
                    x: .value("Mood", mood.label),
                    y: .value("Count", counts[mood] ?? 0)
                )
                .foregroundStyle(Color.indigo.gradient)
                .annotation(position: .top, alignment: .center) {
                    Text(mood.emoji).font(.caption)
                }
            }
            .frame(height: 160)
        }
    }
}

// MARK: – Quick stats

struct StatsCard: View {
    let entries: [MoodEntry]

    private var avgScore: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map(\.mood.score).reduce(0, +) / Double(entries.count)
    }

    private var topMood: Mood? {
        Dictionary(grouping: entries, by: \.mood)
            .max(by: { $0.value.count < $1.value.count })?.key
    }

    private var streak: Int {
        let cal = Calendar.current
        var count = 0
        var day = cal.startOfDay(for: Date())
        while true {
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            if entries.first(where: { $0.date >= day && $0.date < next }) != nil {
                count += 1
                day = cal.date(byAdding: .day, value: -1, to: day)!
            } else { break }
        }
        return count
    }

    var body: some View {
        CardContainer(title: "Stats", icon: "sparkles") {
            HStack(spacing: 0) {
                StatItem(value: String(format: "%.1f", avgScore), label: "Avg Score")
                Divider().frame(height: 44)
                StatItem(value: topMood?.emoji ?? "–", label: "Top Mood")
                Divider().frame(height: 44)
                StatItem(value: "\(streak)d", label: "Streak")
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: – Reusable card wrapper

struct CardContainer<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
