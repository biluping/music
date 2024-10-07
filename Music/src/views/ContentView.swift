import SwiftUI

struct ContentView: View {
    @StateObject private var state = GlobalState.shared
    
    var body: some View {
        Group {
            if state.isLogin {
                MainView()
            } else {
                LoginView()
            }
        }
        .frame(minWidth: 1056, minHeight: 700)
    }
}

#Preview {
    ContentView()
}
