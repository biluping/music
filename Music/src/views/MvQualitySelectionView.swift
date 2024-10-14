import SwiftUI

struct MvQualitySelectionView: View {
    @Binding var sheetShow: Bool
    @ObservedObject private var playbackVM = PlaybackVM.shared
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        VStack {
            Text("选择MV清晰度")
                .font(.headline)
                .padding()
            
            HStack {
                ForEach(playbackVM.currentMvLinks, id: \.name) { mvLink in
                    Button(mvLink.name, action: { playMv(mvLink: mvLink) })
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private func playMv(mvLink: MvLink) {
        playbackVM.togglePause()
        globalState.selectedMenu = "mv"
        playbackVM.playMv(mvLink: mvLink)
        sheetShow.toggle()
    }
}
