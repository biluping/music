import Foundation

class PlatformManager: ObservableObject {
    func savePlatforms(platforms: [Platform]) {
        if let encoded = try? JSONEncoder().encode(platforms) {
            UserDefaults.standard.set(encoded, forKey: "savedPlatforms")
        }
    }
    
    func loadPlatforms() -> [Platform] {
        if let savedPlatforms = UserDefaults.standard.data(forKey: "savedPlatforms"),
           let decodedPlatforms = try? JSONDecoder().decode([Platform].self, from: savedPlatforms) {
            return decodedPlatforms
        } else {
            return []
        }
    }
}