import Foundation
import Alamofire
import SwiftyJSON

class PlatformVM: ObservableObject {
    
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
    
    func fetchPlatforms() {
        let headers: HTTPHeaders = [
            "Cookie": "access_token=\(UserManager.shared.token!)"
        ]
        
        AF.request("https://music.wjhe.top/api/music/list", headers: headers)
            .validate()
            .responseDecodable(of: ResVO<[Platform]>.self) { response in
                switch response.result {
                case .success(let res):
                    if let platforms = res.data {
                        self.savePlatforms(platforms: platforms)
                    }
                case .failure(let err):
                    print("获取平台列表失败", err)
                }
            }
    }
}
