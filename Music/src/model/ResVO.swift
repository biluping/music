struct ResVO<T: Codable>: Codable {
    let common: Common
    let data: T?
}

struct Common: Codable {
    let msg: String
    let code: Int?
}
