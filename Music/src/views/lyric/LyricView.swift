import SwiftUI

struct LyricView: View {

    @StateObject private var playbackVm = PlaybackVM.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("").id(-7)
                    Text("").id(-6)
                    Text("").id(-5)
                    Text("").id(-4)
                    Text("").id(-3)
                    Text("").id(-2)
                    Text("").id(-1)
                    if playbackVm.lyrics.count == 0 {
                        Text("当前没有播放中的歌曲")
                            .foregroundColor(.gray)
                    }
                    ForEach(Array(playbackVm.lyrics.enumerated()), id: \.offset){ index, obj in
                        Text(obj.content)
                            .font(.system(size: playbackVm.currentLyricIndex == index ? 25 : 15))
                            .foregroundColor(playbackVm.currentLyricIndex == index ? .blue : .gray)
                            .lineLimit(1)
                            .id(index)
                    }
                    Text("")
                    Text("")
                    Text("")
                    Text("")
                    Text("")
                    Text("")
                    Text("")
                    Text("")
                }
            }
            .onChange(of: playbackVm.currentLyricIndex) {
                withAnimation(.spring()) {
                    proxy.scrollTo(
                        playbackVm.currentLyricIndex - 7, anchor: .topLeading)
                }
            }
            .onAppear {
                withAnimation(.spring()) {
                    proxy.scrollTo(
                        playbackVm.currentLyricIndex - 7, anchor: .topLeading)
                }
            }
        }
        .navigationTitle("我的歌词")
    }
}
