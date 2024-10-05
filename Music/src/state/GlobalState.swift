import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    
    @Published var selectedPlatformId: String = "kuwo"
    @Published var isLogin = false
    @Published var playList: [Song] = []
    @Published var toast: ToastData?
    
    var platforms: [Platform] {
        get {
            if let platformDicts = UserDefaults.standard.array(forKey: "savedPlatforms") as? [[String: Any]] {
                return platformDicts.compactMap { Platform(dictionary: $0) }
            }
            return []
        }
        set {
            let platformDicts = newValue.map { $0.toDictionary() }
            UserDefaults.standard.set(platformDicts, forKey: "savedPlatforms")
        }
    }
    
    func showToast(_ message: String, type: ToastType) {
        toast = ToastData(message: message, type: type)
        
        // 3秒后自动隐藏Toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.toast = nil
        }
    }
}
