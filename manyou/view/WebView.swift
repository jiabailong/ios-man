import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "jsHandler")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.configuration.preferences.javaScriptEnabled = true
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // 处理导航事件
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated {
                // 处理点击事件
                print("Link activated: \(navigationAction.request.url?.absoluteString ?? "")")
                // 可以在这里处理点击事件的逻辑
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        // 处理 JavaScript 提示框
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("JavaScript alert: \(message)")
            completionHandler()
        }

        // 处理 JavaScript 消息
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "jsHandler" {
                if let messageBody = message.body as? String {
                    print("JavaScript message received: \(messageBody)")
                    NotificationCenter.default.post(name: .navigateToChartView, object: nil)

                    // 在这里处理 JavaScript 发来的消息
                }
            }
        }
    }
}
extension Notification.Name {
    static let navigateToChartView = Notification.Name("navigateToChartView")
}
