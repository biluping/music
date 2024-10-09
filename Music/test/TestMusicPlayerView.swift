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
        "[ver:v1.0]\n[ti:胭脂泪]\n[ar:刘依纯]\n[al:续摊]\n[by:]\n[00:00.000]胭脂泪 - 刘依纯\n[00:10.260]词：张涛\n[00:20.530]曲：舒世豪\n[00:30.803]胭脂泪 黯然留人醉\n[00:36.151]独上西楼人影消瘦 心憔悴\n[00:42.137]问良人 为何不倦归\n[00:47.679]终日苦盼 泪却空垂\n[00:53.123]梦里笑 醒来却是悲\n[00:56.769]无言以对\n[00:59.704]痴情却换得一身负累\n[01:05.865]问一江春水\n[01:08.327]却剪不断伤悲\n[01:11.296]流不尽爱恨离愁的是非\n[01:18.477]如这般滋味\n[01:19.787]在往事中挥泪\n[01:22.970]相思都早已成堆\n[01:59.358]胭脂泪 黯然留人醉\n[02:04.594]独上西楼人影消瘦 心憔悴\n[02:10.779]问良人 为何不倦归\n[02:16.008]终日苦盼 泪却空垂\n[02:21.953]梦里笑 醒来却是悲\n[02:24.684]无言以对\n[02:28.053]痴情却换得一身负累\n[02:34.002]问一江春水\n[02:36.818]却剪不断伤悲\n[02:39.735]流不尽爱恨离愁的是非\n[02:45.727]如这般滋味\n[02:49.213]在往事中挥泪\n[02:51.574]相思都早已成堆\n[02:58.853]问一江春水\n[03:01.486]却剪不断伤悲\n[03:04.535]流不尽爱恨离愁的是非\n[03:10.192]如这般滋味\n[03:13.136]在往事中挥泪\n[03:16.182]相思都早已成堆\n"
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
        if let nextIndex = lyrics.firstIndex(where: { $0.timestamp > audioManager.currentTime }) {
            let currentIndex = max(0, nextIndex - 1)
            let prevIndex = nextIndex - 2
            
            previousLyric = prevIndex < 0 ? "" : lyrics[prevIndex].content
            currentLyric = lyrics[currentIndex].content
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
        let components = timeStr.components(separatedBy: ".")
        if components.count != 2 {
            return nil
        }
        let timeArray = components[0].components(separatedBy: ":")
        guard timeArray.count == 2,
              let minute = Double(timeArray[0]),
            let second = Double(timeArray[1])
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
            Text(currentLyric)
                .font(.system(size: 18))
                .fontWeight(.bold)
            Text(nextLyric)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    TestView()
        .frame(width: 300, height: 100)
}
