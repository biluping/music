import Foundation
import SwiftUI

@Observable
class GlobalState: ObservableObject {
    static let shared = GlobalState()
    private init() {}
    
    var selectedPlatformId: String = "kuwo"
    var selectedMenu = "search"
    var isLogin = false
    var message: String?

    func showErrMsg(_ message: String) {
        self.message = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.message = nil
        }
    }
}
