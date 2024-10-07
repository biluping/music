import SwiftUI

struct NowPlayView: View {
    @StateObject var playbackVM = PlaybackVM.shared

    var body: some View {

        HStack {
            if let cover = playbackVM.currentSongCover {
                cover
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } else {
                Image("songImg")
                    .resizable()
                    .frame(width: 50, height: 50)
            }

            VStack {
                HStack {
                    let songName = playbackVM.currentSong?.name ?? ""
                    let singerName =
                        playbackVM.currentSong?.singers?.map { $0.name }.joined(
                            separator: " / ") ?? ""
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
                        Image(
                            systemName: playbackVM.isPlaying
                                ? "pause.fill" : "play.fill")
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
                        in:
                            0...TimeInterval(
                                playbackVM.currentSong?.duration ?? 0)
                    )
                    .accentColor(.blue)

                    Text(
                        formatTime(
                            TimeInterval(playbackVM.currentSong?.duration ?? 0))
                    )
                    .font(.caption)

                }
            }

            // 添加歌词显示
            Text(playbackVM.currentLyric)
                .font(.title3)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .padding(.top, 4)
                .padding(.leading, 10)
                .frame(width: 300)
        }

    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

}

#Preview {
    NowPlayView()
}
