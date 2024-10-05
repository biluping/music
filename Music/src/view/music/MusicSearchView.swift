import SwiftUI

struct MusicSearchView: View {
    @State private var searchText = ""
    @EnvironmentObject private var state: GlobalState

    var body: some View {
        VStack {
            HStack {
                Picker("平台", selection: $state.selectedPlatformId) {
                    ForEach(state.platforms, id: \.id) { platform in
                        Text(platform.name).tag(platform.id as String?)
                    }
                }
                .frame(width: 150)

                TextField("搜索音乐", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        search()
                    }

                Button(action: search) {
                    Text("搜索")
                }
            }
            .padding(.vertical, 10)
            

            // 展示搜索结果标题
            GeometryReader { geometry in
                VStack {
                    // 展示搜索结果标题
                    HStack{
                        Text("#").bold().frame(width: 50, alignment: .leading)
                        Text("标题").bold().frame(width: geometry.size.width * 0.4, alignment: .leading)
                        Text("专辑").bold().frame(width: geometry.size.width * 0.3, alignment: .leading)
                        Spacer()
                        Text("喜欢").bold().frame(width: 50)
                        Text("时长").bold().frame(width: 50)
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(Array(state.playList.enumerated()), id: \.element.ID) { index, item in
                            HStack {
                                Text("\(index + 1)").frame(width: 50, alignment: .leading)
                                SongTitle().frame(width: geometry.size.width * 0.4, alignment: .leading)
                                Text(item.album?.name ?? "未知").frame(width: geometry.size.width * 0.3, alignment: .leading)
                                Spacer()
                                Image(systemName: "heart").frame(width: 50)
                                Text("\(item.duration ?? 0)").frame(width: 50)
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    
                    
//                    ForEach(self.playList) { item in
//                        HStack {
//                            Text(item.id).frame(width: 50, alignment: .leading)
//                            Text(item.title).frame(width: geometry.size.width * 0.4, alignment: .leading)
//                            Text(item.album).frame(width: geometry.size.width * 0.3, alignment: .leading)
//                            Spacer()
//                            Image(systemName: "heart").frame(width: 50)
//                            Text(item.duration).frame(width: 50)
//                        }
//                        .padding(.vertical, 10)
//                        
//                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle("音乐搜索")
        
    }
    
    func search() {
        MusicApi.shared.getMusicList(platformId: state.selectedPlatformId, name: self.searchText) { songs, err in
            state.playList = songs ?? []
        }
    }
}

// 音乐项目结构体
struct MusicItem: Identifiable {
    let id: String
    let title: String
    let album: String
    let artist: String
    let duration: String
}

#Preview {
    MusicSearchView()
        .environmentObject(GlobalState())
}
