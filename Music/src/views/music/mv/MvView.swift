import SwiftUI
import AVKit

struct MvView: View {
    
    @StateObject private var playbackVM = PlaybackVM.shared
    
    var body: some View {
        ZStack {
            if let player = playbackVM.videoPlayer {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(alignment: .topTrailing) {
                        Menu {
                            ForEach(playbackVM.currentMvLinks, id: \.quality) { mvLink in
                                Button(mvLink.name) {
                                    playbackVM.selectedMvQuality = mvLink.quality
                                    playbackVM.playMv(mvLink: mvLink)
                                }
                            }
                        } label: {
                            Text(playbackVM.currentMvLinks.first(where: { $0.quality == playbackVM.selectedMvQuality })?.name ?? "选择画质")
                                .padding(5)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                        .frame(width: 100)
                        .padding(.top, 7)
                    }
            }
        }
    }
}

#Preview {
    MvView()
        .frame(width: 900, height: 600)
        .onAppear {
            PlaybackVM.shared.videoPlayer = AVPlayer(url: URL(filePath: "/Users/rabbit/Movies/下载/b.mp4"))
        }
}
