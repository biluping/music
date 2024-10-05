import SwiftUI

struct SearchResultItem: View {
    let index: Int
    let song: Song
    let geometryWidth: CGFloat
    @State private var backgroundColor = Color.gray.opacity(0)
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Group {
                if isHovered {
                    Image(systemName: "play.circle")
                        .foregroundColor(.blue)
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
            Image(systemName: "heart").frame(width: 50)
            Text("\(song.duration ?? 0)").frame(width: 50)
        }
        .padding(.vertical, 10)
        .background(backgroundColor)
        .onHover { hovering in
            isHovered = hovering
            withAnimation {
                backgroundColor = hovering ? Color.gray.opacity(0.3) : Color.gray.opacity(0)
            }
        }
    }
}
