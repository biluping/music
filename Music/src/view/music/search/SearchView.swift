import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @EnvironmentObject private var state: GlobalState

    var body: some View {
        VStack {
            HStack {
                Picker("平台", selection: $state.selectedPlatformId) {
                    ForEach(state.loadPlatforms(), id: \.ID) { platform in
                        Text(platform.name).tag(platform.ID)
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
            .padding(10)
            
            SearchResultList()
            
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

#Preview {
    SearchView()
        .environmentObject(GlobalState())
}
