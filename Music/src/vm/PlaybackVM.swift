import Foundation
import AVFoundation
import SwiftUI
import Alamofire

class PlaybackVM: NSObject, ObservableObject {
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var playlist: [Song] = []
    @Published var currentIndex: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    override init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("MusicCache")
        super.init()
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func playSong(_ song: Song, playlist: [Song]) {
        stopCurrentSong()
        currentSong = song
        self.playlist = playlist
        
        if let index = playlist.firstIndex(where: { $0.ID == song.ID }) {
            currentIndex = index
        }
        
        getMusicData(platformId: song.platform, songId: song.ID) { data, error in
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
    
    func getMusicData(platformId: String, songId: String, quality: String = "128", format: String = "mp3", completion: @escaping (Data?, String?) -> Void) {
        let cacheKey = "\(platformId)_\(songId)_\(quality).\(format)"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)
        
        if fileManager.fileExists(atPath: cacheFile.path) {
            do {
                let cachedData = try Data(contentsOf: cacheFile)
                completion(cachedData, nil)
                return
            } catch {
                print("读取缓存文件失败：\(error)")
            }
        }
        
        let urlString = "https://music.wjhe.top/api/music/\(platformId)/url"
        let parameters: [String: String] = [
            "ID": songId,
            "quality": quality,
            "format": format
        ]
        
        let headers: HTTPHeaders = [
            "Cookie": "access_token=\(UserManager.shared.token!)"
        ]
        
        AF.request(urlString, parameters: parameters, headers: headers)
            .response { response in
                if response.response?.statusCode ?? 400 != 200 {
                    completion(nil, "接口\(response.response?.statusCode ?? 400)")
                } else {
                    switch response.result {
                    case .success(let value):
                        print("获取 music data 成功")
                        if let data = value {
                            // 将结果存入文件缓存
                            do {
                                try data.write(to: cacheFile)
                                print("音乐数据已缓存到文件: \(cacheFile.path)")
                            } catch {
                                print("缓存音乐数据到文件失败：\(error)")
                            }
                        }
                        completion(value, nil)
                    case .failure(let error):
                        print("获取 music data 失败", error)
                        completion(nil, error.localizedDescription)
                    }
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

extension PlaybackVM: AVAudioPlayerDelegate {
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
