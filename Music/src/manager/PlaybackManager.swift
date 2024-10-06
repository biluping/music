import Foundation
import AVFoundation
import SwiftUI

class PlaybackManager: NSObject, ObservableObject {
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var playlist: [Song] = []
    @Published var currentIndex: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    func playSong(_ song: Song, playlist: [Song]) {
        stopCurrentSong()
        currentSong = song
        self.playlist = playlist
        
        if let index = playlist.firstIndex(where: { $0.ID == song.ID }) {
            currentIndex = index
        }
        
        MusicApi.shared.getMusicData(platformId: song.platform, songId: song.ID) { data, error in
            guard let data = data else {
                print(error ?? "获取音乐失败")
                return
            }
            
            do {
                let player = try AVAudioPlayer(data: data)
                player.prepareToPlay()
                player.delegate = self
                
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
        isPlaying.toggle()
        if isPlaying {
            audioPlayer?.play()
        } else {
            audioPlayer?.pause()
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
    
    func playNext() {
        currentIndex = (currentIndex + 1) % playlist.count
        if let nextSong = playlist[safe: currentIndex] {
            playSong(nextSong, playlist: self.playlist)
        }
    }
    
    func playPrevious() {
        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        if let previousSong = playlist[safe: currentIndex] {
            playSong(previousSong, playlist: self.playlist)
        }
    }
}

extension PlaybackManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playNext()
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
