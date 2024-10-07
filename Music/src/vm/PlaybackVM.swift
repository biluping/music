import Foundation
import AVFoundation
import SwiftUI
import Alamofire

class PlaybackVM: NSObject, ObservableObject {
    
    static let shared = PlaybackVM()
    
    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var playlist: [Song] = []
    @Published var currentIndex: Int = 0
    @Published var currentSongCover: Image?

    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private override init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("MusicCache")
        super.init()
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    func playSong(_ song: Song, playlist: [Song]) {
        stopCurrentSong()
        currentSong = song
        self.playlist = playlist
        currentIndex = playlist.firstIndex(where: { $0.ID == song.ID }) ?? 0

        // 先获取歌曲封面
        getSongCoverImage(platformId: song.platform, songId: song.ID) { [weak self] image in
            DispatchQueue.main.async {
                self?.currentSongCover = image
            }
            
            // 获取封面后开始播放音乐
            self?.getMusicData(platformId: song.platform, songId: song.ID) { [weak self] data in
                guard let self = self, let data = data else { return }
                
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
                    GlobalState.shared.showErrMsg("音乐播放失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getMusicData(platformId: String, songId: String, quality: String = "128", format: String = "mp3", completion: @escaping (Data?) -> Void) {
        let cacheKey = "\(platformId)_\(songId)_\(quality).\(format)"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)
        
        if let cachedData = try? Data(contentsOf: cacheFile) {
            completion(cachedData)
            return
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
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        try data.write(to: cacheFile)
                        GlobalState.shared.showErrMsg("网络获取音乐成功")
                        completion(data)
                    } catch {
                        GlobalState.shared.showErrMsg("缓存音乐数据到文件失败：\(error)")
                        completion(data)
                    }
                case .failure(let error):
                    GlobalState.shared.showErrMsg("获取 music data 失败, err: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }

    func getSongCoverImage(platformId: String, songId: String, quality: String = "500", format: String = "jpg", completion: @escaping (Image?) -> Void) {
        let cacheKey = "\(platformId)_\(songId)_cover_\(quality).\(format)"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)
        
        if let cachedData = try? Data(contentsOf: cacheFile),
           let uiImage = NSImage(data: cachedData) {
            completion(Image(nsImage: uiImage))
            return
        }
        
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
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let nsImage = NSImage(data: data) {
                        do {
                            try data.write(to: cacheFile)
                            let image = Image(nsImage: nsImage)
                            completion(image)
                        } catch {
                            GlobalState.shared.showErrMsg("缓存封面图片到文件失败：\(error)")
                            completion(Image(nsImage: nsImage))
                        }
                    } else {
                        GlobalState.shared.showErrMsg("无法创建封面图片")
                        completion(nil)
                    }
                case .failure(let error):
                    GlobalState.shared.showErrMsg("获取封面图片失败: \(error.localizedDescription)")
                    completion(nil)
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
        audioPlayer?.currentTime = 0
        currentPlaybackTime = 0
        isPlaying = false
    }
    
    func playNext() {
        currentIndex = (currentIndex + 1) % playlist.count
        if let nextSong = playlist[safe: currentIndex] {
            playSong(nextSong, playlist: playlist)
        }
    }
    
    func playPrevious() {
        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        if let previousSong = playlist[safe: currentIndex] {
            playSong(previousSong, playlist: playlist)
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
