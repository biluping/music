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
                        audioManager.player?.currentTime = audioManager.currentTime
                    }
                )
                
                Text(
                    String(
                        format: "%02d:%02d", Int(audioManager.player?.duration ?? 0) / 60,
                        Int(audioManager.player?.duration ?? 0) % 60)
                )
            }

            HStack {
                Button("播放") {
                    audioManager.player?.play()
                }

                Button("暂停") {
                    audioManager.player?.pause()
                }
            }
        }
        .onAppear(perform: setUp)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if !isDragging {
                audioManager.updateCurrentTime()
            }
        }
    }

    private func setUp() {
        guard let asset = NSDataAsset(name: "music") else { return }
        audioManager.setupPlayer(with: asset)
    }
}

#Preview {
    TestView()
        .frame(width: 300, height: 100)
}
