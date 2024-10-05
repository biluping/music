import SwiftUI

struct SearchResultList: View {
    @EnvironmentObject private var state: GlobalState

    var body: some View {
        GeometryReader { geometry in
            VStack {
                // 展示搜索结果标题
                HStack {
                    Text("#").bold().frame(width: 50)
                    Text("标题").bold().frame(width: geometry.size.width * 0.4, alignment: .leading)
                    Text("专辑").bold().frame(width: geometry.size.width * 0.3, alignment: .leading)
                    Spacer()
                    Text("喜欢").bold().frame(width: 50)
                    Text("时长").bold().frame(width: 50)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(Array(state.playList.enumerated()), id: \.element.ID) { index, item in
                        SearchResultItem(index: index, song: item, geometryWidth: geometry.size.width)
                    }
                }
            }
        }
    }
}

struct SearchResultList_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultList()
            .environmentObject(GlobalState())
    }
}
