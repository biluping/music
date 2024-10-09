import AVFoundation
import SwiftUI


struct TestView: View {
    @State private var isDragging = false
    @State private var lyrics: [(timestamp: Double, content: String)] = []
    @State private var displayLyrics: [String] = []
    @State private var currentLyricIndex: Int = 0
    @State private var currentTime: TimeInterval = 0
    @State var player: AVAudioPlayer?
    
    let numberOfLyricsToDisplay: Int = 5 // You can change this value as needed

    private let lyric =
        "[ver:v1.0]\n[ar:张杰]\n[ti:天下]\n[by:v_emilylu]\n[00:00.001]天下 - 张杰\n[00:01.327]词：周毅\n[00:01.429]曲：刘吉宁\n[00:01.560]编曲：张峰棣/吴牧禅\n[00:01.858]制作人：闻震/张杰\n[00:02.112]Guitar：程冠琨\n[00:02.242]二胡：董小闻\n[00:02.423]和音编写&和音：张杰\n[00:02.695]混音：周天澈@Studio21A\n[00:02.907]母带：Chris Gehringer@Steling Sound NY\n[00:03.117]监制&出品人：张杰\n[00:03.367]制作&发行：行星文化Planet Culture\n[00:27.185]烽烟起寻爱似浪淘沙\n[00:33.866]遇见她如春水映梨花\n[00:40.534]挥剑断天涯相思轻放下\n[00:47.307]梦中我痴痴牵挂\n[00:54.295]顾不顾将相王侯\n[00:55.797]管不管万世千秋\n[00:57.404]求只求爱化解\n[00:59.217]这万丈红尘纷乱永无休\n[01:01.668]爱更爱天长地久\n[01:03.197]要更要似水温柔\n[01:04.889]谁在乎谁主春秋\n[01:07.234]一生有爱何惧风飞沙\n[01:10.458]悲白发留不住芳华\n[01:14.185]抛去江山如画\n[01:15.750]换她笑面如花\n[01:17.420]抵过这一生空牵挂\n[01:20.605]心若无怨爱恨也随她\n[01:23.835]天地大情路永无涯\n[01:27.478]只为她袖手天下\n[02:00.713]顾不顾将相王侯\n[02:02.441]管不管万世千秋\n[02:04.121]求只求爱化解\n[02:05.940]这万丈红尘纷乱永无休\n[02:08.249]爱更爱天长地久\n[02:09.944]要更要似水温柔\n[02:11.592]谁在乎谁主春秋\n[02:14.003]一生有爱何惧风飞沙\n[02:17.102]悲白发留不住芳华\n[02:20.827]抛去江山如画\n[02:22.419]换她笑面如花\n[02:24.107]抵过这一生空牵挂\n[02:27.166]心若无怨爱恨也随她\n[02:30.364]天地大情路永无涯\n[02:33.981]只为她袖手天下\n[02:40.768]一生有爱何惧风飞沙\n[02:43.766]悲白发留不住芳华\n[02:47.466]抛去江山如画\n[02:49.119]换她笑面如花\n[02:50.775]抵过这一生空牵挂\n[02:53.827]心若无怨爱恨也随她\n[02:57.055]天地大情路永无涯\n[03:00.636]只为她袖手天下\n[03:07.303]烽烟起寻爱似浪淘沙\n[03:13.771]遇见她如春水映梨花\n[03:20.465]挥剑断天涯相思轻放下\n[03:27.279]梦中我痴痴牵挂\n"

    var body: some View {
        VStack {
            playerControls
            lyricDisplayView
                .padding(.top, 20)
        }
        .onAppear(perform: setUp)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if !isDragging {
                currentTime = player?.currentTime ?? 0
                updateLyrics()
            }
        }
    }
    
    private var playerControls: some View {
        HStack {
            Text(timeString(from: currentTime))
            Slider(
                value: $currentTime,
                in: 0...(player?.duration ?? 0),
                onEditingChanged: { isDragging in
                    self.isDragging = isDragging
                    player?.currentTime = currentTime
                }
            )
            Text(timeString(from: player?.duration ?? 0))
            Button("播放") {
                player?.play()
            }
            Button("暂停") {
                player?.pause()
            }
        }
    }
    
    private var lyricDisplayView: some View {
        VStack(spacing: 8) {
            ForEach(Array(displayLyrics.enumerated()), id: \.offset) { index, content in
                Text(content)
                    .font(.system(size: index == currentLyricIndex ? 18 : 14))
                    .fontWeight(index == currentLyricIndex ? .bold : .regular)
                    .foregroundColor(index == currentLyricIndex ? .primary : .gray)
                    .lineLimit(1)
            }
        }
    }

    private func updateLyrics() {
        guard let nextIndex = lyrics.firstIndex(where: { $0.timestamp > currentTime }) else { return }
        
        let currentIndex = nextIndex - 1
        let startIndex = max(0, currentIndex - (numberOfLyricsToDisplay / 2))
        let endIndex = min(lyrics.count - 1, startIndex + numberOfLyricsToDisplay - 1)
        
        displayLyrics = Array(lyrics[startIndex...endIndex].map { $0.content })
        currentLyricIndex = currentIndex - startIndex
        
        // Pad with empty strings if not enough lyrics
        displayLyrics += Array(repeating: "", count: max(0, numberOfLyricsToDisplay - displayLyrics.count))
        currentLyricIndex = min(currentLyricIndex, displayLyrics.count - 1)
    }

    private func setUp() {
        guard let asset = NSDataAsset(name: "music") else { return }
        player = try? AVAudioPlayer(data: asset.data)
        parseLyrics()
    }

    private func parseLyrics() {
        lyrics = lyric.components(separatedBy: .newlines)
            .compactMap { line -> (timestamp: Double, content: String)? in
                let components = line.components(separatedBy: "]")
                guard components.count == 2,
                      let timeStr = components.first?.trimmingCharacters(in: CharacterSet(charactersIn: "[]")),
                      let time = parseTimeStr(timeStr: timeStr) else { return nil }
                return (timestamp: time, content: components[1])
            }
    }

    private func parseTimeStr(timeStr: String) -> Double? {
        let components = timeStr.components(separatedBy: ":")
        guard components.count == 2,
              let minute = Double(components[0]),
              let second = Double(components[1])
        else { return nil }
        return minute * 60 + second
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TestView()
        .frame(width: 500, height: 300)
}
