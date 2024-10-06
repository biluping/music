import SwiftUI

struct NowPlayView: View {
    @EnvironmentObject var state: GlobalState
    @EnvironmentObject var playbackManager: PlaybackManager
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            HStack {
                let songName = playbackManager.currentSong?.name ?? ""
                let singerName = playbackManager.currentSong?.singers?.map {$0.name}.joined(separator: " / ") ?? ""
                Text("\(songName) - \(singerName)")
                Spacer()
                
                Button(action: {
                    playbackManager.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                }.buttonStyle(PlainButtonStyle())

                Button(action: {
                    playbackManager.togglePlayPause()
                }) {
                    Image(systemName: playbackManager.isPlaying ? "pause.fill" : "play.fill")
                }.buttonStyle(PlainButtonStyle())
            
                Button(action: {
                    playbackManager.stopCurrentSong()
                }) {
                    Image(systemName: "stop.fill")
                }.buttonStyle(PlainButtonStyle())
            
                
                Button(action: {
                    playbackManager.playNext()
                }) {
                    Image(systemName: "forward.fill")
                }.buttonStyle(PlainButtonStyle())
            }
            
            HStack {
                    
                Text(formatTime(playbackManager.currentPlaybackTime))
                    .font(.caption)
                
                Slider(
                    value: Binding(
                        get: { playbackManager.currentPlaybackTime },
                        set: { newValue in
                            playbackManager.seekTo(time: newValue)
                        }),
                    in: 0...TimeInterval(playbackManager.currentSong?.duration ?? 0)
                    )
                .accentColor(.blue)
                
                Text(formatTime(TimeInterval(playbackManager.currentSong?.duration ?? 0 )))
                    .font(.caption)
                
            }
        }
    }
}

#Preview {
    NowPlayView()
}
