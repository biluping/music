import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI

class MusicApi {
    static let shared = MusicApi()
    
    private init() {}
    
    func getHeader() -> HTTPHeaders {
        return [
            "Cookie": "access_token=\(UserManager.shared.token!)"
        ]
    }
    
    func getPlatformList(completion: @escaping ([Platform]?, String?) -> Void) {
        AF.request("https://music.wjhe.top/api/music/list", headers: getHeader())
            .responseString { response in
                switch response.result {
                case .success(let value):
                    do {
                        let json = JSON(parseJSON: value)
                        let platforms = try json["data"].arrayValue.map { platformJson -> Platform in
                            let platformData = try JSONSerialization.data(withJSONObject: platformJson.object)
                            return try JSONDecoder().decode(Platform.self, from: platformData)
                        }
                        print("平台获取成功", platforms)
                        completion(platforms, nil)
                    } catch {
                        print("解析平台数据失败")
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let err):
                    print("获取平台列表失败")
                    completion(nil, err.localizedDescription)
                }
            }
    }
    
    func getMusicList(platformId: String, name: String, completion: @escaping ([Song]?, String?) -> Void) {
        let paramters:[String: String] = [
            "key": name,
            "pageIndex": "1",
            "pageSize": "20"
        ]
        AF.request("https://music.wjhe.top/api/music/\(platformId)/search", parameters: paramters, headers: getHeader())
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSON(data: data)
                        let songsData = json["data"]["data"].arrayValue
                        let songs = try songsData.map { songJson in
                            let songData = try JSONSerialization.data(withJSONObject: songJson.dictionaryObject ?? [:], options: [])
                            return try JSONDecoder().decode(Song.self, from: songData)
                        }
                        print("搜索歌曲成功", songs)
                        completion(songs, nil)
                    } catch {
                        print("JSON解析失败：\(error)")
                        completion(nil, error.localizedDescription)
                    }
                case .failure(let err):
                    print("获取音乐列表失败")
                    completion(nil, err.localizedDescription)
                }
            }
    }
    
    func getMusicData(platformId: String, songId: String, quality: String = "128", format: String = "mp3", completion: @escaping (Data?, String?) -> Void) {
        let urlString = "https://music.wjhe.top/api/music/\(platformId)/url"
        let parameters: [String: String] = [
            "ID": songId,
            "quality": quality,
            "format": format
        ]
        
        AF.request(urlString, parameters: parameters, headers: getHeader())
            .response { response in
                switch response.result {
                case .success(let value):
                    print("获取 music data 成功")
                    completion(value, nil)
                case .failure(let error):
                    print("获取 music data 失败", error)
                    completion(nil, error.localizedDescription)
                }
            }
    }
    
    // 其他API方法(搜索、获取音乐URL等)将在这里实现
}
