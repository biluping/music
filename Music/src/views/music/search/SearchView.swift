import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searching = false
    @StateObject private var musicVM = MusicVM.shared
    @StateObject private var plantformVM = PlatformVM.shared
    @StateObject private var state = GlobalState.shared

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack {
                    Picker("平台", selection: $state.selectedPlatformId) {
                        ForEach(plantformVM.loadPlatforms(), id: \.ID) { platform in
                            Text(platform.name).tag(platform.ID)
                        }
                    }
                    .frame(width: 150)
                    
                    TextField("搜索音乐", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit(search)
                    
                    Button(action: search) {
                        Text("搜索")
                    }
                }
                .padding(10)
                
                if !musicVM.musicList.isEmpty {
                    SearchResultList(playlist: musicVM.musicList)
                } else {
                    Text("没有搜索结果")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            
            if searching {
                ProgressView()
            }
        }
        .navigationTitle("音乐搜索")
    }
    
    private func search() {
        searching = true
        musicVM.getMusicList(platformId: state.selectedPlatformId, name: searchText) {
            searching = false
        }
    }
}

#Preview {
    SearchView()
}
