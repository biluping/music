import SwiftUI

struct ContentView: View {
    @StateObject private var state = GlobalState.shared
    
    var body: some View {
        Group {
//            if state.isLogin {
//                MainView()
//            } else {
//                LoginView()
//            }
            MainView()
        }
        .overlay(
            Group {
                if let message = state.message {
                    PopupView(message: message)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        )
        .animation(.easeInOut, value: state.message != nil)
    }
}

struct PopupView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 600)
}
