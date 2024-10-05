import SwiftUI

struct LoginView: View {
    @State private var username = "linuxdo"
    @State private var password = "linuxdo"
    @State private var isLoading = false
    @State private var msg = ""
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var state: GlobalState

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.5), Color.purple.opacity(0.5),
                ]), startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // 标题
                Text("音乐世界")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(msg)
                    .foregroundColor(.red)
                    .frame(width: 100, height: 30)
                    .font(.callout)

                Group {
                    // 用户名输入框
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                        TextField("用户名", text: $username)
                            .textFieldStyle(PlainTextFieldStyle())
                    }

                    // 密码输入框
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("密码", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                    }

                }
                .padding()
                .background(Color(colorScheme == .dark ? .black : .white))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

                // 登录按钮
                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("登录")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue, Color.purple,
                                    ]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                    }
                    
                }
                .disabled(isLoading)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                .buttonStyle(BorderlessButtonStyle()) // 添加这一行来移除边框
            }
            .font(.system(size: 20))
            .padding(.horizontal, 100)
        }
    }

    func login() {
        UserManager.shared.login(username: username, password: password) {
            success, error in
            isLoading = false
            if success {
                self.msg = error ?? "登录成功"
                print("登录成功")
                MusicApi.shared.getPlatformList() { platformList, errMsg in
                    if let platforms = platformList {
                        state.platforms = platforms
                    } else {
                        print(errMsg ?? "获取平台列表失败")
                    }
                }
                // 登录成功,跳转到主界面
                state.isLogin = true
            } else {
                self.msg = error ?? "登录失败,请重试"
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(GlobalState())
}
