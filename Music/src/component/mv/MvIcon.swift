import SwiftUI

struct MvIcon: View {
    var song: Song
    @State private var sheetShow = false
    @ObservedObject private var playbackVM = PlaybackVM.shared
    @ObservedObject private var globalState = GlobalState.shared

    var body: some View {
        Text("MV")
            .font(.system(size: 7))
            .foregroundStyle(.red)
            .padding(2)
            .border(Color.red)
            .cornerRadius(3)
            .onTapGesture(perform: fetchMvData)
    }
    
    private func fetchMvData() {
        playbackVM.getMvData(platformId: song.platform, songId: song.ID)
    }
}
