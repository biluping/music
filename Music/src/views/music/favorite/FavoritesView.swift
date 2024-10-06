import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var state: GlobalState
    @StateObject var favoritesVM = FavoritesVM()
    
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
        .navigationTitle("我的收藏")
    }
}

#Preview {
    FavoritesView()
        .environmentObject(GlobalState())
}
