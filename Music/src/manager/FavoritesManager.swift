import Foundation

class FavoritesManager: ObservableObject {
    @Published var favoriteSongs: [Song] = [] {
        didSet {
            saveFavoriteSongs()
        }
    }
    
    init() {
        loadFavoriteSongs()
    }
    
    func toggleFavorite(_ song: Song) {
        if let index = favoriteSongs.firstIndex(where: { $0.ID == song.ID }) {
            favoriteSongs.remove(at: index)
        } else {
            favoriteSongs.append(song)
        }
    }
    
    func isFavorite(_ song: Song) -> Bool {
        return favoriteSongs.contains(where: { $0.ID == song.ID })
    }
    
    private func saveFavoriteSongs() {
        if let encoded = try? JSONEncoder().encode(favoriteSongs) {
            UserDefaults.standard.set(encoded, forKey: "favoriteSongs")
        }
    }
    
    private func loadFavoriteSongs() {
        if let savedFavoriteSongs = UserDefaults.standard.data(forKey: "favoriteSongs"),
           let decodedFavoriteSongs = try? JSONDecoder().decode([Song].self, from: savedFavoriteSongs) {
            favoriteSongs = decodedFavoriteSongs
        }
    }
}
