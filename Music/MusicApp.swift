import AppKit
import SwiftData
import SwiftUI

@main
struct MusicApp: App {
    
    @StateObject private var state = GlobalState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
        }
    }
}
