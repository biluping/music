import SwiftUI

struct NowPlayView: View {
    @StateObject var playbackVM = PlaybackVM.shared
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            HStack {
                let songName = playbackVM.currentSong?.name ?? ""
                let singerName = playbackVM.currentSong?.singers?.map {$0.name}.joined(separator: " / ") ?? ""
                Text("\(songName) - \(singerName)")
                Spacer()
                
                Button(action: {
                    playbackVM.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                }.buttonStyle(PlainButtonStyle())

                Button(action: {
                    playbackVM.togglePlayPause()
                }) {
                    Image(systemName: playbackVM.isPlaying ? "pause.fill" : "play.fill")
                }.buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    playbackVM.playNext()
                }) {
                    Image(systemName: "forward.fill")
                }.buttonStyle(PlainButtonStyle())
            }
            
            HStack {
                    
                Text(formatTime(playbackVM.currentPlaybackTime))
                    .font(.caption)
                
                Slider(
                    value: Binding(
                        get: { playbackVM.currentPlaybackTime },
                        set: { newValue in
                            playbackVM.seekTo(time: newValue)
                        }),
                    in: 0...TimeInterval(playbackVM.currentSong?.duration ?? 0)
                    )
                .accentColor(.blue)
                
                Text(formatTime(TimeInterval(playbackVM.currentSong?.duration ?? 0 )))
                    .font(.caption)
                
            }
        }
    }
}

#Preview {
    NowPlayView()
        .environmentObject(PlaybackVM())
}
