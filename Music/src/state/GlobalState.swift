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
    var audioPlayer: AVAudioPlayer?
    
    var platforms: [Platform] {
        get {
            if let platformDicts = UserDefaults.standard.array(forKey: "savedPlatforms") as? [[String: Any]] {
                return platformDicts.compactMap { Platform(dictionary: $0) }
            }
            return []
        }
        set {
            let platformDicts = newValue.map { $0.toDictionary() }
            UserDefaults.standard.set(platformDicts, forKey: "savedPlatforms")
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
                    self.currentSong = song
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
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }
}
