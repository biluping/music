/// 表示单首歌曲的结构
struct Song: Codable {
    /// 歌曲标题
    let title: String?
    /// 歌曲名称
    let name: String?
    /// 歌曲ID
    let ID: String
    /// 歌曲时长（秒）
    let duration: Int?
    /// MV ID，可能不存在
    let mvID: String?
    /// 专辑信息
    let album: Album?
    /// 歌手列表
    let singers: [Singer]?
    /// 文件链接列表
    let fileLinks: [FileLink]?
    /// 音乐平台
    let platform: String
    /// 副标题，可能不存在
    let subTitle: String?
}

/// 专辑信息结构
struct Album: Codable {
    /// 专辑ID
    let ID: String
    /// 专辑名称
    let name: String?
}

/// 歌手信息结构
struct Singer: Codable {
    /// 歌手ID
    let ID: String
    /// 歌手名称
    let name: String
}

/// 文件链接信息结构
struct FileLink: Codable {
    /// 文件名
    let name: String?
    /// 音质（kbps）
    let quality: Int
    /// 文件格式
    let format: String
    /// 文件大小（字节）
    let size: Int?
}

