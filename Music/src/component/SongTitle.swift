import SwiftUI

struct SongTitle: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("惊鸿一面")
                .foregroundColor(.blue)
                .font(.title3)
            
            HStack(spacing: 4) {
                Text("超清母带")
                    .font(.system(size: 8))
                    .foregroundStyle(Color("gold"))
                    .padding(2)
                    .border(Color("gold"))
                    .cornerRadius(3)
                
                Text("MV")
                    .font(.system(size: 8))
                    .foregroundStyle(.red)
                    .padding(2)
                    .border(Color(.red))
                    .cornerRadius(3)
                
                Text("许嵩 / 黄龄")
                    .font(.headline)
                    .foregroundStyle(Color("pale"))
            }
            
        }
    }
}

#Preview {
    SongTitle().frame(width: 200, height: 100)
}
