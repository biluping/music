import AppKit
import SwiftData
import SwiftUI

@main
struct MusicApp: App {
    @StateObject private var state = GlobalState()

    var body: some Scene {
        WindowGroup {
            Group {
                if state.isLogin {
                    MainView()
                } else {
                    LoginView()
                }
            }
            .frame(minWidth: 1056, minHeight: 700)
            .environmentObject(state)
        }
    }
}
