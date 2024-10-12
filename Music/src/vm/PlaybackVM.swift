import AVFoundation
import Alamofire
import Foundation
import SwiftUI

class PlaybackVM: NSObject, ObservableObject, AVAudioPlayerDelegate {

    static let shared = PlaybackVM()

    @Published var currentSong: Song?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var playlist: [Song] = []
    @Published var playlistIndex: Int = 0
    @Published var currentSongCoverData: Data?
    @Published var currentLyricIndex = 0
    @Published var audioPlayer: AVAudioPlayer?
    @Published var lyrics: [(timeStamp: TimeInterval, content: String)] = []
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private override init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("MusicCache")
        super.init()
        try? fileManager.createDirectory(
            at: cacheDirectory, withIntermediateDirectories: true,
            attributes: nil)
    }

    // 实现 AVAudioPlayerDelegate 协议，音乐播放结束后，自动播放下一首
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playNext()
        }
    }

    // 更新当前 music 状态，例如：歌词、
    func updateCurrentMusicState() {
        currentTime = audioPlayer?.currentTime ?? 0
        currentLyricIndex = lyrics.lastIndex(where: { $0.timeStamp <= currentTime }) ?? 0
    }

    func playSong(_ song: Song, playlist: [Song]) {
        isPlaying = false
        audioPlayer?.currentTime = 0
        audioPlayer?.stop()

        currentSong = song
        self.playlist = playlist
        self.currentLyricIndex = 0
        playlistIndex = playlist.firstIndex(where: { $0.ID == song.ID }) ?? 0

        // 获取音乐
        getMusicData(platformId: song.platform, songId: song.ID) {data in
            guard let data = data else { return }

            DispatchQueue.main.async {
                self.audioPlayer = try? AVAudioPlayer(data: data)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.play()
                self.isPlaying = true
            }
        }

        // 获取封面
        getSongCoverImage(platformId: song.platform, songId: song.ID) { data in
            if let data = data {
                DispatchQueue.main.async {
                    self.currentSongCoverData = data
                }
            }
        }

        // 获取歌词
        getLyricData(platformId: song.platform, songId: song.ID) {data in
            if let data = data {
                self.parseLyrics(String(data: data, encoding: .utf8)!)
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
                    let timeString = components[0].trimmingCharacters(
                        in: CharacterSet(charactersIn: "[]"))
                    let content = components[1].trimmingCharacters(
                        in: .whitespacesAndNewlines)

                    if let timeStamp = parseTimeStamp(timeString) {
                        lyrics.append((timeStamp: timeStamp, content: content))
                    }
                }
            }
        }

        lyrics.sort { $0.timeStamp < $1.timeStamp }
    }

    private func parseTimeStamp(_ timeString: String) -> TimeInterval? {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
            let minutes = Double(components[0]),
            let seconds = Double(components[1])
        else {
            return nil
        }
        return minutes * 60 + seconds
    }

    func getMusicData(
        platformId: String, songId: String, quality: String = "128",
        format: String = "mp3", completion: @escaping (Data?) -> Void
    ) {
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
            "format": format,
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
                    GlobalState.shared.showErrMsg(
                        "获取 music data 失败, err: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }

    func getSongCoverImage(
        platformId: String, songId: String, quality: String = "500",
        format: String = "jpg", completion: @escaping (Data?) -> Void
    ) {
        let cacheKey = "\(platformId)_\(songId)_cover_\(quality).\(format)"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)

        if let cachedData = try? Data(contentsOf: cacheFile) {
            completion(cachedData)
            return
        }

        let urlString = "https://music.wjhe.top/api/music/\(platformId)/url"
        let parameters: [String: String] = [
            "ID": songId,
            "quality": quality,
            "format": format,
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
                        GlobalState.shared.showErrMsg("获取封面成功")
                        completion(data)
                    } catch {
                        GlobalState.shared.showErrMsg("缓存封面图片到文件失败：\(error)")
                        completion(nil)
                    }
                case .failure(let error):
                    GlobalState.shared.showErrMsg(
                        "获取封面图片失败: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }

    func getLyricData(
        platformId: String, songId: String,
        completion: @escaping (Data?) -> Void
    ) {
        let cacheKey = "\(platformId)_\(songId).lyric"
        let cacheFile = cacheDirectory.appendingPathComponent(cacheKey)

        // 尝试从缓存中读取歌词数据
        if let cachedData = try? Data(contentsOf: cacheFile) {
            completion(cachedData)
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
                    if let lyricData = res.data!.lyric.data(using: .utf8) {
                        do {
                            try lyricData.write(to: cacheFile)
                            GlobalState.shared.showErrMsg("歌词缓存成功")
                            completion(lyricData)
                        } catch {
                            GlobalState.shared.showErrMsg("缓存歌词到文件失败：\(error)")
                            completion(nil)
                        }
                    } else {
                        GlobalState.shared.showErrMsg("歌词数据转换失败")
                        completion(nil)
                    }
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

    func playNext() {
        playlistIndex = (playlistIndex + 1) % playlist.count
        playSong(playlist[playlistIndex], playlist: playlist)
    }

    func playPrevious() {
        playlistIndex = (playlistIndex - 1 + playlist.count) % playlist.count
        playSong(playlist[playlistIndex], playlist: playlist)
    }
}
