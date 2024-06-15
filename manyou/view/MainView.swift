import SwiftUI
import WebKit

struct MainView: View {
    @State private var navigateToChart = false
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, work, life, me
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .home:
                        WebView(url: URL(string: "http://39.101.191.170:8080/manyou/home.html")!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .overlay(
                                NavigationLink(destination: SSEChatView(), isActive: $navigateToChart) {
                                    EmptyView()
                                }
                            )
                        
                    case .work:
                        WebView(url: URL(string: "http://39.101.191.170:8080/manyou/wk.html")!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .overlay(
                                NavigationLink(destination: SSEChatView(), isActive: $navigateToChart) {
                                    EmptyView()
                                }
                            )
                    case .life:
                        WebView(url: URL(string: "http://39.101.191.170:8080/manyou/comfort.html")!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .overlay(
                                NavigationLink(destination: SSEChatView(), isActive: $navigateToChart) {
                                    EmptyView()
                                }
                            )
                    case .me:
                        WebView(url: URL(string: "http://39.101.191.170:8080/manyou/mine.html")!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .overlay(
                                NavigationLink(destination: SSEChatView(), isActive: $navigateToChart) {
                                    EmptyView()
                                }
                            )
                    }
                    
                    // 固定大小的标签栏在底部
                    HStack {
                        Button(action: {
                            self.selectedTab = .home
                        }) {
                            Text("首页")
                        }
                        Spacer()
                        Button(action: {
                            self.selectedTab = .work
                        }) {
                            Text("工作助手")
                        }
                        Spacer()
                        Button(action: {
                            self.selectedTab = .life
                        }) {
                            Text("生活助手")
                        }
                        Spacer()
                        Button(action: {
                            self.selectedTab = .me
                        }) {
                            Text("我的")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(1))
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
            .navigationBarHidden(true) // 隐藏导航栏
        }
    }
}



struct SecondPageView: View {
    var body: some View {
        Text("Second Page")
    }
}

struct ThirdPageView: View {
    var body: some View {
        Text("Third Page")
    }
}

struct FourthPageView: View {
    var body: some View {
        Text("Fourth Page")
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
