import Foundation
import Alamofire
import SwiftUI

class MusicVM: ObservableObject {
    
    static let shared = MusicVM()
    private init() {}
    
    @Published var musicList: [Song] = []
    
    func getHeader() -> HTTPHeaders {
        return [
            "Cookie": "access_token=\(UserVM.shared.token!)"
        ]
    }
    
    func getMusicList(platformId: String, name: String, completion: @escaping () -> Void) {
        let paramters:[String: String] = [
            "key": name,
            "pageIndex": "1",
            "pageSize": "20"
        ]
        AF.request("https://music.wjhe.top/api/music/\(platformId)/search", parameters: paramters, headers: getHeader())
            .validate()
            .responseDecodable(of: ResVO<PageData<Song>>.self) { response in
                switch response.result {
                case .success(let res):
                    if let songs = res.data?.data {
                        self.musicList = songs
                    } else {
                        debugPrint(response)
                        GlobalState.shared.showErrMsg("搜索音乐发生异")
                    }
                case .failure(let err):
                    debugPrint(response)
                    GlobalState.shared.showErrMsg("搜索音乐发生异常：" + err.localizedDescription)
                }
                completion()
            }
    }
}
