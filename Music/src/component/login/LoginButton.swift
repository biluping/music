import SwiftUI

struct LoginButton: View {
    var isLoading: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 按钮背景
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .cornerRadius(10)
                
                // 按钮内容
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("登录")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 50)
        }
        .disabled(isLoading)
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
        .buttonStyle(BorderlessButtonStyle())
    }
}

#Preview {
    VStack {
        LoginButton(isLoading: false, action: {})
        LoginButton(isLoading: true, action: {})
    }
}
