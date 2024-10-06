import SwiftUI

struct Platform: Codable {
    let ID: String
    let name: String
    let shortName: String
    let order: Int
    let tags: [String]
}
