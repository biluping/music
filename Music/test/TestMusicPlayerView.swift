import AVFoundation
import SwiftUI

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentTime: TimeInterval = 0
    var player: AVAudioPlayer?

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer, successfully flag: Bool
    ) {
        print("播放结束")
    }

    func setupPlayer(with asset: NSDataAsset) {
        guard let player = try? AVAudioPlayer(data: asset.data) else {
            print("Failed to initialize audio player")
            return
        }
        self.player = player
        player.delegate = self
    }

    func updateCurrentTime() {
        currentTime = player?.currentTime ?? 0
    }
}

struct TestView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var isDragging = false

    private let lyric =
        "[ver:v1.0]\n[ar:张杰]\n[ti:天下]\n[by:v_emilylu]\n[00:00.001]天下 - 张杰\n[00:01.327]词：周毅\n[00:01.429]曲：刘吉宁\n[00:01.560]编曲：张峰棣/吴牧禅\n[00:01.858]制作人：闻震/张杰\n[00:02.112]Guitar：程冠琨\n[00:02.242]二胡：董小闻\n[00:02.423]和音编写&和音：张杰\n[00:02.695]混音：周天澈@Studio21A\n[00:02.907]母带：Chris Gehringer@Steling Sound NY\n[00:03.117]监制&出品人：张杰\n[00:03.367]制作&发行：行星文化Planet Culture\n[00:27.185]烽烟起寻爱似浪淘沙\n[00:33.866]遇见她如春水映梨花\n[00:40.534]挥剑断天涯相思轻放下\n[00:47.307]梦中我痴痴牵挂\n[00:54.295]顾不顾将相王侯\n[00:55.797]管不管万世千秋\n[00:57.404]求只求爱化解\n[00:59.217]这万丈红尘纷乱永无休\n[01:01.668]爱更爱天长地久\n[01:03.197]要更要似水温柔\n[01:04.889]谁在乎谁主春秋\n[01:07.234]一生有爱何惧风飞沙\n[01:10.458]悲白发留不住芳华\n[01:14.185]抛去江山如画\n[01:15.750]换她笑面如花\n[01:17.420]抵过这一生空牵挂\n[01:20.605]心若无怨爱恨也随她\n[01:23.835]天地大情路永无涯\n[01:27.478]只为她袖手天下\n[02:00.713]顾不顾将相王侯\n[02:02.441]管不管万世千秋\n[02:04.121]求只求爱化解\n[02:05.940]这万丈红尘纷乱永无休\n[02:08.249]爱更爱天长地久\n[02:09.944]要更要似水温柔\n[02:11.592]谁在乎谁主春秋\n[02:14.003]一生有爱何惧风飞沙\n[02:17.102]悲白发留不住芳华\n[02:20.827]抛去江山如画\n[02:22.419]换她笑面如花\n[02:24.107]抵过这一生空牵挂\n[02:27.166]心若无怨爱恨也随她\n[02:30.364]天地大情路永无涯\n[02:33.981]只为她袖手天下\n[02:40.768]一生有爱何惧风飞沙\n[02:43.766]悲白发留不住芳华\n[02:47.466]抛去江山如画\n[02:49.119]换她笑面如花\n[02:50.775]抵过这一生空牵挂\n[02:53.827]心若无怨爱恨也随她\n[02:57.055]天地大情路永无涯\n[03:00.636]只为她袖手天下\n[03:07.303]烽烟起寻爱似浪淘沙\n[03:13.771]遇见她如春水映梨花\n[03:20.465]挥剑断天涯相思轻放下\n[03:27.279]梦中我痴痴牵挂\n"

    @State private var lyrics: [(timestamp: Double, content: String)] = []
    @State private var previousLyric = ""
    @State private var currentLyric = ""
    @State private var nextLyric = ""

    var body: some View {
        VStack {
            HStack {
                Text(
                    String(
                        format: "%02d:%02d", Int(audioManager.currentTime) / 60,
                        Int(audioManager.currentTime) % 60)
                )

                Slider(
                    value: $audioManager.currentTime,
                    in: 0...(audioManager.player?.duration ?? 0),
                    onEditingChanged: { isDragging in
                        self.isDragging = isDragging
                        audioManager.player?.currentTime =
                            audioManager.currentTime
                    }
                )

                Text(
                    String(
                        format: "%02d:%02d",
                        Int(audioManager.player?.duration ?? 0) / 60,
                        Int(audioManager.player?.duration ?? 0) % 60)
                )

                Button("播放") {
                    audioManager.player?.play()
                }

                Button("暂停") {
                    audioManager.player?.pause()
                }
            }

            LyricDisplayView(
                previousLyric: previousLyric,
                currentLyric: currentLyric,
                nextLyric: nextLyric
            )
        }
        .onAppear(perform: setUp)
        .onReceive(
            Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        ) { _ in
            if !isDragging {
                audioManager.updateCurrentTime()
                updateLyrics()
            }
        }
    }

    private func updateLyrics() {
        if let nextIndex = lyrics.firstIndex(where: {
            $0.timestamp > audioManager.currentTime
        }) {
            let currentIndex = nextIndex - 1
            let prevIndex = nextIndex - 2

            previousLyric = prevIndex < 0 ? "" : lyrics[prevIndex].content
            currentLyric = currentIndex < 0 ? "" : lyrics[currentIndex].content
            nextLyric = lyrics[nextIndex].content
        }
    }

    private func setUp() {
        guard let asset = NSDataAsset(name: "music") else { return }
        audioManager.setupPlayer(with: asset)

        // 解析歌词
        let lines = lyric.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("[") && line.contains("]") {
                let components = line.components(separatedBy: "]")
                if components.count == 2 {
                    let timeStr = components[0].trimmingCharacters(
                        in: CharacterSet(charactersIn: "[]"))
                    let content = components[1]
                    if let time = parseTimeStr(timeStr: timeStr) {
                        lyrics.append((timestamp: time, content: content))
                    }
                }
            }
        }
    }

    private func parseTimeStr(timeStr: String) -> Double? {
        let components = timeStr.components(separatedBy: ":")
        guard components.count == 2,
            let minute = Double(components[0]),
            let second = Double(components[1])
        else {
            return nil
        }
        return minute * 60 + second
    }
}

struct LyricDisplayView: View {
    let previousLyric: String
    let currentLyric: String
    let nextLyric: String

    var body: some View {
        VStack(spacing: 8) {
            Text(previousLyric)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
            Text(currentLyric)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .lineLimit(1)
            Text(nextLyric)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

#Preview {
    TestView()
        .frame(width: 300, height: 300)
}
