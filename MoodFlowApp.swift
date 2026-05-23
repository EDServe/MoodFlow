import SwiftUI

@main
struct MoodFlowApp: App {
    @StateObject private var store = MoodStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
