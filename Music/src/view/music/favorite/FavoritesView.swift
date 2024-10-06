import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var state: GlobalState
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        VStack {
            if favoritesManager.favoriteSongs.isEmpty {
                Text("还没有收藏的歌曲")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                SearchResultList(playlist: favoritesManager.favoriteSongs)
            }
        }
        .navigationTitle("我的收藏")
    }
}

#Preview {
    FavoritesView()
        .environmentObject(GlobalState())
}
