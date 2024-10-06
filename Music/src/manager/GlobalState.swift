import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    @Published var selectedPlatformId: String = "kuwo"
    @Published var isLogin = false
    @Published var toast: ToastData?
    
    @Published var errorMsg: String?

    func showErrMsg(_ message: String) {
        self.errorMsg = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.errorMsg = nil
        }
    }
}
