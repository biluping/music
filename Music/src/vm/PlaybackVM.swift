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
    @Published var currentLyric: String = ""
    private var lyrics: [(timeStamp: TimeInterval, content: String)] = []
    
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
        self.currentLyric = ""
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
        
        // 获取歌词
        getLyricData(platformId: song.platform, songId: song.ID) { [weak self] lyricData in
            if let lyricData = lyricData {
                self?.parseLyrics(lyricData.lyric)
            }
        }
    }
    
    private func parseLyrics(_ lyricsString: String) {
        lyrics.removeAll()
        let lines = lyricsString.components(separatedBy: .newlines)
        
        for line in lines {
            if line.hasPrefix("[") && line.contains("]") {
                let components = line.components(separatedBy: "]")
                if components.count >= 2 {
                    let timeString = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                    let content = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if let timeStamp = parseTimeStamp(timeString) {
                        lyrics.append((timeStamp: timeStamp, content: content))
                    }
                }
            }
        }
        
        print(lyrics)
        
        lyrics.sort { $0.timeStamp < $1.timeStamp }
    }
    
    private func parseTimeStamp(_ timeString: String) -> TimeInterval? {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]) else {
            return nil
        }
        return minutes * 60 + seconds
    }
    
    private func updateCurrentLyric() {
        guard !lyrics.isEmpty else { return }
        
        let currentTime = currentPlaybackTime
        if let currentLyric = lyrics.last(where: { $0.timeStamp <= currentTime }) {
            self.currentLyric = currentLyric.content
        } else {
            self.currentLyric = ""
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

    func getLyricData(platformId: String, songId: String, completion: @escaping (LyricData?) -> Void) {
        let cacheKey = "\(platformId)_\(songId)_lyric"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)
        
        // 尝试从缓存中读取歌词数据
        if let cachedData = try? Data(contentsOf: cacheFile),
           let lyricData = try? JSONDecoder().decode(LyricData.self, from: cachedData) {
            completion(lyricData)
            return
        }
        
        let urlString = "https://music.wjhe.top/api/music/\(platformId)/lyric"
        let parameters: [String: String] = [
            "ID": songId
        ]
        
        let headers: HTTPHeaders = [
            "Cookie": "access_token=\(UserVM.shared.token!)"
        ]
        
        AF.request(urlString, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: ResVO<LyricData>.self) { response in
                switch response.result {
                case .success(let res):
                    // 将歌词数据缓存到磁盘
                    if let encodedData = try? JSONEncoder().encode(res.data) {
                        do {
                            try encodedData.write(to: cacheFile)
                        } catch {
                            GlobalState.shared.showErrMsg("缓存歌词数据到文件失败：\(error)")
                        }
                    }
                    completion(res.data)
                case .failure(let error):
                    GlobalState.shared.showErrMsg("获取歌词数据失败: \(error)")
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
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentPlaybackTime = self.audioPlayer?.currentTime ?? 0
            self.updateCurrentLyric()
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
