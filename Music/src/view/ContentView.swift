import SwiftUI

struct ContentView: View {
    
    @StateObject private var state = GlobalState()
    
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if state.isLogin {
                    MainView()
                } else {
                    LoginView()
                }
            }
            .frame(minWidth: 1056, minHeight: 700)
            
            if let toastData = state.toast {
                VStack {
                    Spacer()
                    ToastView(message: toastData.message, type: toastData.type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: state.toast != nil)
                        .zIndex(1)
                }
            }
        }
        .environmentObject(state)
    }
}

#Preview {
    ContentView()
}
