import SwiftUI
import AVFoundation

struct SearchResultItem: View {
    let index: Int
    let song: Song
    let geometryWidth: CGFloat
    let playlist: [Song]
    @State private var backgroundColor = Color.gray.opacity(0)
    @State private var isHovered = false
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var playbackManager: PlaybackManager
    
    var body: some View {
        HStack {
            Group {
                if isHovered {
                    Image(systemName: playbackManager.isPlaying && playbackManager.currentSong?.ID == song.ID ? "pause" : "play")
                        .foregroundColor(.blue)
                        .font(.title3)
                        .onTapGesture {
                            handlePlayPause()
                        }
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                } else {
                    Text("\(index + 1)")
                }
            }
            .frame(width: 50)
            SongTitle(song: song).frame(width: geometryWidth * 0.4, alignment: .leading)
            Text(song.album?.name ?? "未知").frame(width: geometryWidth * 0.3, alignment: .leading)
            Spacer()
            Button(action: {
                favoritesManager.toggleFavorite(song)
            }) {
                Image(systemName: favoritesManager.isFavorite(song) ? "heart.fill" : "heart")
                    .foregroundColor(favoritesManager.isFavorite(song) ? .red : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 50)
            Text(formatDuration(song.duration ?? 0)).frame(width: 50)
        }
        .padding(.vertical, 10)
        .background(backgroundColor)
        .onHover { hovering in
            isHovered = hovering
            withAnimation {
                backgroundColor = hovering ? Color.gray.opacity(0.3) : Color.gray.opacity(0)
            }
        }
        .onTapGesture(count: 2) {
            handlePlayPause()
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func handlePlayPause() {
        if playbackManager.currentSong?.ID == song.ID {
            playbackManager.togglePlayPause()
        } else {
            playbackManager.playSong(song, playlist: playlist)
        }
    }
}
