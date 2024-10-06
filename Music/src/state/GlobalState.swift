import Foundation
import SwiftUI
import AVFoundation

class GlobalState: ObservableObject {
    
    @Published var selectedPlatformId: String = "kuwo"
    @Published var isLogin = false
    @Published var toast: ToastData?
    
    // 播放music相关state
    @Published var playList: [Song] = []
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentPlaybackTime: TimeInterval = 0
    var audioPlayer: AVAudioPlayer?
    var playbackTimer: Timer?

    
    func savePlatforms(platforms: [Platform]) {
        if let encoded = try? JSONEncoder().encode(platforms) {
            UserDefaults.standard.set(encoded, forKey: "savedPlatforms")
        }
    }
    
    func loadPlatforms() -> [Platform] {
        if let savedPlatforms = UserDefaults.standard.data(forKey: "savedPlatforms"),
           let decodedPlatforms = try? JSONDecoder().decode([Platform].self, from: savedPlatforms) {
            return decodedPlatforms
        } else {
            return []
        }
    }

    func showToast(_ message: String, type: ToastType) {
        toast = ToastData(message: message, type: type)
        
        // 3秒后自动隐藏Toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.toast = nil
        }
    }
    
    func playSong(_ song: Song) {
        self.stopCurrentSong()
        self.currentSong = song
        
        MusicApi.shared.getMusicData(platformId: song.platform, songId: song.ID) { data, error in
            guard let data = data else {
                print("无法获取音乐")
                return
            }
            
            do {
                let player = try AVAudioPlayer(data: data)
                player.prepareToPlay()
                
                DispatchQueue.main.async {
                    self.audioPlayer = player
                    self.audioPlayer?.play()
                    self.startPlaybackTimer()
                    self.isPlaying = true
                }
                
            } catch {
                print("播放失败: \(error.localizedDescription)")
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            audioPlayer?.play()
            isPlaying = true
        }
    }

    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.currentPlaybackTime = self?.audioPlayer?.currentTime ?? 0
        }
    }

    func seekTo(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    func stopCurrentSong() {
        audioPlayer?.stop()
        seekTo(time: 0)
        audioPlayer?.currentTime = 0
        currentPlaybackTime = 0
        isPlaying = false
    }
}
