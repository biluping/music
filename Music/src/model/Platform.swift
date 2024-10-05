import SwiftyJSON
import Foundation

struct Platform: Codable {
    let id: String
    let name: String
    let shortName: String
    let order: Int
    let tags: [String]
    
    init(json: JSON) {
        id = json["ID"].stringValue
        name = json["name"].stringValue
        shortName = json["shortName"].stringValue
        order = json["order"].intValue
        tags = json["tags"].arrayValue.map { $0.stringValue }
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let shortName = dictionary["shortName"] as? String,
              let order = dictionary["order"] as? Int,
              let tags = dictionary["tags"] as? [String] else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.shortName = shortName
        self.order = order
        self.tags = tags
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "shortName": shortName,
            "order": order,
            "tags": tags
        ]
    }
}
