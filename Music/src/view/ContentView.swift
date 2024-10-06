import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var state: GlobalState
    
    var body: some View {
        Group {
            if state.isLogin {
                MainView()
            } else {
                LoginView()
            }
        }
        .frame(minWidth: 1056, minHeight: 700)
        .environmentObject(FavoritesManager())
        .environmentObject(PlatformManager())
        .environmentObject(PlaybackManager())
    }
}

#Preview {
    ContentView()
        .environmentObject(GlobalState())
}
