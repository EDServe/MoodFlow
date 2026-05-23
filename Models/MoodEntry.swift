import Foundation

enum Mood: String, CaseIterable, Codable {
    case rad      = "rad"
    case good     = "good"
    case meh      = "meh"
    case bad      = "bad"
    case awful    = "awful"

    var emoji: String {
        switch self {
        case .rad:   return "😄"
        case .good:  return "🙂"
        case .meh:   return "😐"
        case .bad:   return "😔"
        case .awful: return "😢"
        }
    }

    var label: String { rawValue.capitalized }

    var color: String {
        switch self {
        case .rad:   return "MoodRad"
        case .good:  return "MoodGood"
        case .meh:   return "MoodMeh"
        case .bad:   return "MoodBad"
        case .awful: return "MoodAwful"
        }
    }

    // Numeric value for charting (1–5)
    var score: Double {
        switch self {
        case .awful: return 1
        case .bad:   return 2
        case .meh:   return 3
        case .good:  return 4
        case .rad:   return 5
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mood: Mood
    var note: String

    var dayString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
