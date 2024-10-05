import SwiftUI

struct ToastData {
    let message: String
    let type: ToastType
}

enum ToastType {
    case success
    case warning
    case message
    case error
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .message: return "info.circle"
        case .error: return "xmark.circle"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: return .green
        case .warning: return .orange
        case .message: return .blue
        case .error: return .red
        }
    }
}