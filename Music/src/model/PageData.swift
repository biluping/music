struct PageData<T: Codable>: Codable {
    let key: String
    let pagingVO: PagingVO
    let data: [T]
}

struct PagingVO: Codable {
    let pageIndex: Int
    let pageSize: Int
    let totalNum: Int
}
