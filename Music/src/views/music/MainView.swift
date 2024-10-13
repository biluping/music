import SwiftUI

struct MainView: View {
    @StateObject private var state = GlobalState.shared
    @StateObject private var playbackVM = PlaybackVM.shared

    var body: some View {
        NavigationSplitView {
            List(selection: $state.selectedMenu) {
                NavigationLink(value: "search") {
                    Label("音乐搜索", systemImage: "magnifyingglass")
                }
                NavigationLink(value: "favorites") {
                    Label("我的收藏", systemImage: "heart.fill")
                }
                NavigationLink(value: "lyric") {
                    Label("我的歌词", systemImage: "music.note.list")
                }
            }
            .navigationTitle("音乐世界")
        } detail: {
            Group {
                switch state.selectedMenu {
                case "search":
                    SearchView()
                case "favorites":
                    FavoritesView()
                case "lyric":
                    LyricView()
                default:
                    Text("请选择一个菜单项")
                }
            }
        }
        .toolbar {
            if playbackVM.currentSong != nil {
                ToolbarItem(placement: .status) {
                    NowPlayView()
                        .frame(width: 600)
                }
            }
        }
    }
}

#Preview {
    MainView()
        .frame(minWidth: 1000, minHeight: 600)
}
