import SwiftUI

struct FavoritesView: View {
    @StateObject var favoritesVM = FavoritesVM.shared
    
    var body: some View {
        VStack {
            if favoritesVM.favoriteSongs.isEmpty {
                Text("还没有收藏的歌曲")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                SearchResultList(playlist: favoritesVM.favoriteSongs)
            }
        }
    }
}

#Preview {
    FavoritesView()
}
