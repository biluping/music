import Foundation
import Alamofire

class UserVM {
    static let shared = UserVM()
    private init() {}
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "userToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userToken")
        }
    }
    
    func login(username: String, password: String, completion: @escaping (String?) -> Void) {
        let parameters: [String: String] = [
            "userID": username,
            "password": password
        ]
        
        AF.request("https://music.wjhe.top/api/user/login", 
                   method: .post, 
                   parameters: parameters, 
                   encoder: URLEncodedFormParameterEncoder.default)
            .responseDecodable(of: ResVO<LoginData>.self) { response in
                switch response.result {
                case .success(let res):
                    if let data = res.data {
                        self.token = data.token
                        completion(nil)
                    } else {
                        GlobalState.shared.showErrMsg(res.common.msg)
                        completion(res.common.msg)
                    }
                case .failure(let error):
                    GlobalState.shared.showErrMsg(error.localizedDescription)
                    completion(error.localizedDescription)
                }
            }
    }
    
    func logout() {
        token = nil
    }
}
