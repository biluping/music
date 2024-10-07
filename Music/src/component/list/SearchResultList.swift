import SwiftUI

struct SearchResultList: View {
    let playlist: [Song]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) { // 添加 spacing: 0 来移除默认间距
                // 展示搜索结果标题
                HStack {
                    Text("#").bold().frame(width: 50)
                    Text("标题").bold().frame(width: geometry.size.width * 0.4, alignment: .leading)
                    Text("专辑").bold().frame(width: geometry.size.width * 0.3, alignment: .leading)
                    Spacer()
                    Text("喜欢").bold().frame(width: 50)
                    Text("时长").bold().frame(width: 50)
                }
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) { // 使用 LazyVStack 并设置 spacing: 0
                        ForEach(Array(playlist.enumerated()), id: \.element.ID) { index, item in
                            SearchResultItem(index: index, song: item, geometryWidth: geometry.size.width, playlist: playlist)
                            
                            if index < playlist.count - 1 {
                                Divider() // 在每个项目之间添加分隔线
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SearchResultList_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultList(playlist: [])
    }
}
