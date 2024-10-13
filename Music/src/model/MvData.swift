struct MvData: Codable {
    let ID: String
    let links: [MvLink]
    let name: String
    let picUrl: String?
    let platform: String
}

struct MvLink: Codable {
    let URL: String
    let format: String
    let name: String
    let quality: Int

}
