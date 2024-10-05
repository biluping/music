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
                    let json = JSON(parseJSON: value)
                    let platforms = json["data"].arrayValue.map { Platform(json: $0) }
                    print("平台获取成功", platforms)
                    completion(platforms, nil)
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
    
    // 其他API方法(搜索、获取音乐URL等)将在这里实现
}
