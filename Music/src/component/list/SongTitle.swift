import SwiftUI

struct SongTitle: View {
    
    var song: Song
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(song.title ?? "未知title")
                .foregroundColor(.blue)
                .font(.title3)
            
            HStack(spacing: 4) {
                
                if song.fileLinks?.contains(where: { $0.format == "flac" }) == true {
                    Text("超清母带")
                        .font(.system(size: 7))
                        .foregroundStyle(Color("gold"))
                        .padding(2)
                        .border(Color("gold"))
                        .cornerRadius(3)
                }
                
                if song.mvID != nil {
                    Text("MV")
                        .font(.system(size: 7))
                        .foregroundStyle(.red)
                        .padding(2)
                        .border(Color(.red))
                        .cornerRadius(3)
                }
                
                
                Text(song.singers?.map { $0.name }.joined(separator: " / ") ?? "未知歌手")
                    .font(.subheadline)
                    .foregroundStyle(Color("pale"))
            }
            
        }
    }
}

#Preview {
    
    let song = Song(title: "惊鸿一面", name: "惊鸿一面", ID: "4856712", duration: 111, mvID: "4856712", album: nil, singers: [Singer(ID: "11", name: "许嵩"), Singer(ID: "11", name: "黄龄")], fileLinks: [FileLink(name: "flac", quality: 2000, format: "flac", size: 28689040)], platform: nil, subTitle: nil)
    
    SongTitle(song: song).frame(width: 200, height: 100)
}
