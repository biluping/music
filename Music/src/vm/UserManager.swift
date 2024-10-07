import Foundation
import Alamofire
import SwiftyJSON

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
    
    func login(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        let parameters: [String: String] = [
            "userID": username,
            "password": password
        ]
        
        AF.request("https://music.wjhe.top/api/user/login", 
                   method: .post, 
                   parameters: parameters, 
                   encoder: URLEncodedFormParameterEncoder.default)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(parseJSON: value)
                    if let token = json["data"]["token"].string {
                        self.token = token
                        completion(true, nil)
                    } else {
                        completion(false, json["common"]["msg"].string)
                    }
                case .failure(let error):
                    print(response.value ?? "null")
                    completion(false, error.localizedDescription)
                }
            }
    }
    
    func logout() {
        token = nil
    }
}
