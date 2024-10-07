import Foundation
import AVFoundation
import SwiftUI
import Alamofire

class PlaybackVM: NSObject, ObservableObject {
    
    static let shared = PlaybackVM()
    private override init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("MusicCache")
        super.init()
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var playlist: [Song] = []
    @Published var currentIndex: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    
    func playSong(_ song: Song, playlist: [Song]) {
        stopCurrentSong()
        currentSong = song
        self.playlist = playlist
        
        if let index = playlist.firstIndex(where: { $0.ID == song.ID }) {
            currentIndex = index
        }
        
        getMusicData(platformId: song.platform, songId: song.ID) { data in
            if data == nil {
                return
            }
            
            do {
                let player = try AVAudioPlayer(data: data!)
                player.prepareToPlay()
                player.delegate = self
                
                DispatchQueue.main.async {
                    self.audioPlayer = player
                    self.audioPlayer?.play()
                    self.startPlaybackTimer()
                    self.isPlaying = true
                }
            } catch {
                GlobalState.shared.showErrMsg("音乐播放失败: \(error.localizedDescription)")
            }
        }
    }
    
    func getMusicData(platformId: String, songId: String, quality: String = "128", format: String = "mp3", completion: @escaping (Data?) -> Void) {
        let cacheKey = "\(platformId)_\(songId)_\(quality).\(format)"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)
        
        if fileManager.fileExists(atPath: cacheFile.path) {
            do {
                let cachedData = try Data(contentsOf: cacheFile)
                completion(cachedData)
                return
            } catch {
                GlobalState.shared.showErrMsg("读取缓存文件失败：\(error)")
            }
        }
        
        GlobalState.shared.showErrMsg("正在网络获取音乐")
        let urlString = "https://music.wjhe.top/api/music/\(platformId)/url"
        let parameters: [String: String] = [
            "ID": songId,
            "quality": quality,
            "format": format
        ]
        
        let headers: HTTPHeaders = [
            "Cookie": "access_token=\(UserVM.shared.token!)"
        ]
        
        AF.request(urlString, parameters: parameters, headers: headers)
            .response { response in
                if response.response!.statusCode != 200 {
                    GlobalState.shared.showErrMsg("接口错误: \(response.response!.statusCode)")
                    completion(nil)
                } else {
                    switch response.result {
                    case .success(let value):
                        if let data = value {
                            do {
                                try data.write(to: cacheFile)
                            } catch {
                                GlobalState.shared.showErrMsg("缓存音乐数据到文件失败：\(error)")
                            }
                        }
                        GlobalState.shared.showErrMsg("网络获取音乐成功")
                        completion(value)
                    case .failure(let error):
                        GlobalState.shared.showErrMsg("获取 music data 失败, err: " + error.localizedDescription)
                        completion(nil)
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
