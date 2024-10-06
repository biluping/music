import SwiftUI

struct NowPlayView: View {
    @EnvironmentObject var state: GlobalState
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            HStack {
                let songName = state.currentSong?.name ?? ""
                let singerName = state.currentSong?.singers?.map {$0.name}.joined(separator: " / ") ?? ""
                Text("\(songName) - \(singerName)")
                Spacer()
                
                Button(action: {
                    state.togglePlayPause()
                }) {
                    Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                }.buttonStyle(PlainButtonStyle())
            
                Button(action: {
                    state.stopCurrentSong()
                }) {
                    Image(systemName: "stop.fill")
                }.buttonStyle(PlainButtonStyle())
                
            }
            
            HStack {
                    
                Text(formatTime(state.currentPlaybackTime))
                    .font(.caption)
                
                Slider(
                    value: Binding(
                        get: { state.currentPlaybackTime },
                        set: { newValue in
                            state.seekTo(time: newValue)
                        }),
                        in: 0...TimeInterval(state.currentSong?.duration ?? 0)
                    )
                .accentColor(.blue)
                
                Text(formatTime(TimeInterval(state.currentSong?.duration ?? 0 )))
                    .font(.caption)
                
            }
        }
    }
}

#Preview {
    NowPlayView()
}
