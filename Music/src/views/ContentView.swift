import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var state: GlobalState
    
    var body: some View {
        Group {
            if state.isLogin {
                MainView()
            } else {
                LoginView(plantformVM: PlatformVM())
            }
        }
        .frame(minWidth: 1056, minHeight: 700)
    }
}

#Preview {
    ContentView()
        .environmentObject(GlobalState())
}
