import SwiftUI

// NowPlayView 结构体定义了当前播放界面的视图
struct NowPlayView: View {
    @StateObject private var state = GlobalState.shared
    @StateObject private var playbackVM = PlaybackVM.shared
    @StateObject private var favoritesVM = FavoritesVM.shared
    @State private var isDragging = false
    @State private var selectedQuality = 128

    // 主体视图
    var body: some View {
        HStack {
            coverImageButton
            
            VStack(spacing: 0) {
                songInfoAndControlsRow
                progressSliderRow
            }
            
            lyricsView
        }
        // 定时器，用于更新音乐播放状态
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if !isDragging {
                playbackVM.updateCurrentMusicState()
            }
        }
    }
    
    // 封面图片按钮视图
    private var coverImageButton: some View {
        Button(action: { state.selectedMenu = "lyric" }) {
            if let coverData = playbackVM.currentSongCoverData {
                Image(nsImage: NSImage(data: coverData)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } else {
                Image("songImg")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 歌曲信息和控制按钮行视图
    private var songInfoAndControlsRow: some View {
        HStack {
            songInfoView
            Spacer()
            playbackControlsView
            Spacer()
            qualityPickerView
            Spacer()
            mvAndFavoriteButtons
        }
    }
    
    // 歌曲信息视图
    private var songInfoView: some View {
        let songName = playbackVM.currentSong?.name ?? ""
        let singerName = playbackVM.currentSong?.singers?.map { $0.name }.joined(separator: " / ") ?? ""
        return Text("\(songName) - \(singerName)")
    }
    
    // 播放控制按钮视图
    private var playbackControlsView: some View {
        HStack {
            Button(action: { playbackVM.playPrevious() }) {
                Image(systemName: "backward.fill")
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: { playbackVM.togglePlayPause() }) {
                Image(systemName: playbackVM.isPlaying ? "pause.fill" : "play.fill")
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: { playbackVM.playNext() }) {
                Image(systemName: "forward.fill")
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // 音质选择器视图
    private var qualityPickerView: some View {
        Picker("", selection: $selectedQuality) {
            ForEach(playbackVM.currentSong?.fileLinks ?? [], id: \.name) { fileLink in
                if fileLink.format != "ogg" {
                    Text(fileLink.name).tag(fileLink.quality)
                }
            }
        }
        .frame(width: 90)
        .onChange(of: selectedQuality) {
            if let song = playbackVM.currentSong {
                playbackVM.playSong(song, playlist: playbackVM.playlist, quality: selectedQuality)
            }
        }
    }
    
    // MV和收藏按钮视图
    private var mvAndFavoriteButtons: some View {
        HStack {
            if let song = playbackVM.currentSong, playbackVM.currentSong?.mvID != nil {
                MvIcon(song: song)
            }
            
            if let song = playbackVM.currentSong {
                Button(action: { favoritesVM.toggleFavorite(song) }) {
                    Image(systemName: favoritesVM.isFavorite(song) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesVM.isFavorite(song) ? .red : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 10)
            }
        }
    }
    
    // 进度条视图
    private var progressSliderRow: some View {
        HStack {
            Text(formatTime(playbackVM.currentTime))
                .font(.caption)
            
            Slider(
                value: $playbackVM.currentTime,
                in: 0...(playbackVM.audioPlayer?.duration ?? 0),
                onEditingChanged: { isDragging in
                    self.isDragging = isDragging
                    playbackVM.audioPlayer?.currentTime = playbackVM.currentTime
                }
            )
            
            Text(formatTime(TimeInterval(playbackVM.currentSong?.duration ?? 0)))
                .font(.caption)
        }
    }
    
    // 歌词视图
    private var lyricsView: some View {
        Group {
            if playbackVM.lyrics.count > 0 {
                Text(playbackVM.lyrics[playbackVM.currentLyricIndex].content)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.top, 4)
                    .padding(.leading, 10)
                    .frame(width: 200)
                    .onTapGesture {
                        state.selectedMenu = "lyric"
                    }
            }
        }
    }

    // 格式化时间的辅助函数
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// 预览提供器
#Preview {
    NowPlayView()
}
