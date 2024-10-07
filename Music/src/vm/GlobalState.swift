import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    static let shared = GlobalState()
    private init() {}
    
    @Published var selectedPlatformId: String = "kuwo"
    @Published var isLogin = false
    @Published var message: String?

    func showErrMsg(_ message: String) {
        self.message = message
        print(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.message = nil
        }
    }
}
