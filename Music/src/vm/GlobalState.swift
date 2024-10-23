import Foundation
import SwiftUI
import OSLog

let logger = Logger(subsystem: "com.myboy.music", category: "main")

@Observable
class GlobalState: ObservableObject {
    static let shared = GlobalState()
    private init() {}
    
    var selectedPlatformId: String = "kuwo"
    var selectedMenu = "search"
    var isLogin = true
    var message: String?

    func showErrMsg(_ message: String) {
        logger.warning("music log: \(message)")
        self.message = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.message = nil
        }
    }
}
