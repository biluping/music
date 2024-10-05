import SwiftUI

struct FavoritesView: View {
    var body: some View {
        Text("我的收藏将显示在这里")
            .navigationTitle("我的收藏")
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}