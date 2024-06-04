import SwiftUI

struct MainView: View {
    @State private var navigateToChart = false
    
    var body: some View {
        VStack(spacing: 0) {
            // WebView 占据上方的剩余空间
            WebView(url: URL(string: "http://39.101.191.170:8080/manyou/homeios.html")!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            
            NavigationLink(destination: SSEChatView(), isActive: $navigateToChart) {
                EmptyView()
            }
            
            // 固定大小的标签栏在底部
            HStack {
                Text("Tab 1")
                Spacer()
                Text("Tab 2")
                Spacer()
                Text("Tab 3")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .frame(height: 50) // 固定高度
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .navigateToChartView, object: nil, queue: .main) { _ in
                self.navigateToChart = true
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .navigateToChartView, object: nil)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
