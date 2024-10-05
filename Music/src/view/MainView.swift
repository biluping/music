import SwiftUI

struct MainView: View {
    @State private var selectedMenu: String? = "search"

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedMenu) {
                NavigationLink(value: "search") {
                    Label("音乐搜索", systemImage: "magnifyingglass")
                }
                NavigationLink(value: "favorites") {
                    Label("我的收藏", systemImage: "heart.fill")
                }
            }
            .navigationTitle("音乐世界")
        } detail: {
            Group {
                switch selectedMenu {
                case "search":
                    MusicSearchView()
                case "favorites":
                    FavoritesView()
                default:
                    Text("请选择一个菜单项")
                }
            }.padding(.horizontal, 20)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(GlobalState())
}
