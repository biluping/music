import SwiftUI

struct SplitView: View {
    // 示例数据
    let items = ["Item 1", "Item 2", "Item 3"]
    
    // 选中的项
    @State private var selectedItem: String? = nil
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(items, id: \.self, selection: $selectedItem) { item in
                Text(item)
            }
            .navigationTitle("Items")
        } content: {
            // Content
            if let selectedItem = selectedItem {
                Text("Selected: \(selectedItem)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Select an item")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } detail: {
            // Detail (optional)
            if let selectedItem = selectedItem {
                Text("Detail of: \(selectedItem)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Select an item for details")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SplitView()
    }
}
