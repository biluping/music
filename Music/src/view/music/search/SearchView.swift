import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @EnvironmentObject private var state: GlobalState
    @EnvironmentObject private var platformManager: PlatformManager
    @State private var searching = false
    @State private var playlist: [Song] = []

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                SearchBar(searchText: $searchText, onSearch: search)
                
                if !playlist.isEmpty {
                    SearchResultList(playlist: playlist)
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
        MusicApi.shared.getMusicList(platformId: state.selectedPlatformId, name: searchText) { songs, errMsg in
            if let errMsg = errMsg {
                print(errMsg)
            } else {
                DispatchQueue.main.async {
                    playlist = songs ?? []
                    searching = false
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    @EnvironmentObject private var state: GlobalState
    @EnvironmentObject private var platformManager: PlatformManager
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            PlatformPicker()
            
            TextField("搜索音乐", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit(onSearch)
            
            Button(action: onSearch) {
                Text("搜索")
            }
        }
        .padding(10)
    }
}

struct PlatformPicker: View {
    @EnvironmentObject private var state: GlobalState
    @EnvironmentObject private var platformManager: PlatformManager
    
    var body: some View {
        Picker("平台", selection: $state.selectedPlatformId) {
            ForEach(platformManager.loadPlatforms(), id: \.ID) { platform in
                Text(platform.name).tag(platform.ID)
            }
        }
        .frame(width: 150)
    }
}

#Preview {
    SearchView()
        .environmentObject(GlobalState())
        .environmentObject(PlatformManager())
}
