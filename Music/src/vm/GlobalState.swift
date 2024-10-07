import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    static let shared = GlobalState()
    
    @Published var selectedPlatformId: String = "kuwo"
    @Published var isLogin = false
    @Published var message: String?

    private init() {}

    func showErrMsg(_ message: String) {
        self.message = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.message = nil
        }
    }
}
