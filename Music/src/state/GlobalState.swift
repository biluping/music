import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    
    @Published var selectedPlatformId: String = "kuwo"
    @Published var isLogin = false
    @Published var playList: [Song] = []
    
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
}
