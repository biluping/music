import SwiftUI

struct MainView: View {
    @State private var selectedMenu: String? = "search"
    @EnvironmentObject private var state: GlobalState
    @EnvironmentObject private var playbackManager: PlaybackManager

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
                    SearchView()
                case "favorites":
                    FavoritesView()
                default:
                    Text("请选择一个菜单项")
                }
            }
        }
        .toolbar {
            if playbackManager.currentSong != nil {
                ToolbarItem(placement: .principal) {
                    NowPlayView()
                        .frame(width: 300)
                }
            }
            
            if let errMsg = state.errorMsg {
                ToolbarItem(placement: .automatic) {
                    Text(errMsg)
                }
            }
        }
    }
}

#Preview {
    MainView()
        .frame(minWidth: 1056, minHeight: 700)
        .environmentObject(GlobalState())
        .environmentObject(FavoritesManager())
        .environmentObject(PlatformManager())
        .environmentObject(PlaybackManager())
}
