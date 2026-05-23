import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: MoodStore

    @State private var selected: Mood?
    @State private var note: String = ""
    @State private var saved = false
    @FocusState private var noteFocused: Bool

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 4) {
                        Text(greeting)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("How are you feeling?")
                            .font(.largeTitle.bold())
                    }
                    .padding(.top, 24)

                    // Mood picker
                    HStack(spacing: 12) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            MoodButton(mood: mood, isSelected: selected == mood) {
                                withAnimation(.spring(response: 0.3)) {
                                    selected = mood
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Note field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a note")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))

                            if note.isEmpty {
                                Text("What's on your mind?")
                                    .foregroundStyle(.tertiary)
                                    .padding(16)
                            }

                            TextEditor(text: $note)
                                .focused($noteFocused)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .frame(minHeight: 100)
                        }
                    }
                    .padding(.horizontal)

                    // Save button
                    Button {
                        guard let mood = selected else { return }
                        store.add(mood: mood, note: note)
                        withAnimation { saved = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { saved = false }
                            selected = nil
                            note = ""
                            noteFocused = false
                        }
                    } label: {
                        Label(saved ? "Saved!" : "Log Mood",
                              systemImage: saved ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selected == nil ? Color.gray.opacity(0.3) : Color.indigo)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(selected == nil || saved)
                    .padding(.horizontal)
                    .animation(.default, value: saved)

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("MoodFlow")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture { noteFocused = false }
        }
    }
}

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: isSelected ? 40 : 32))
                Text(mood.label)
                    .font(.caption2.bold())
                    .foregroundStyle(isSelected ? .indigo : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.indigo.opacity(0.12) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
