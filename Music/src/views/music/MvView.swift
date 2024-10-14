import SwiftUI
import AVKit

struct MvView: View {
    
    @StateObject private var playbackVM = PlaybackVM.shared
    
    var body: some View {
        ZStack {
            if let player = playbackVM.videoPlayer {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
    MvView()
        .frame(width: 900, height: 600)
}
