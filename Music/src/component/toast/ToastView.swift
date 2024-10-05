import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    
    var body: some View {
        HStack {
            Image(systemName: type.iconName)
            Text(message)
        }
        .frame(width: 300)
        .padding(4)
        .background(type.backgroundColor)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

#Preview {
    ToastView(message: "hello world", type: ToastType.success)
}
