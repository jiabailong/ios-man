//
//  WebHandler.swift
//  manyou
//
//  Created by jiabailong1 on 2024/6/3.
//

import SwiftUI
import WebKit

class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    var parent: WebView

    init(parent: WebView) {
        self.parent = parent
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("JavaScript message received: \(message.name)")
        if message.name == "Bridge" {
            if let messageBody = message.body as? String {
                print("JavaScript message received: \(messageBody)")
                parent.navigationTrigger = true
            }
        }
    }
    
    // 处理导航事件
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Page Loaded: \(webView.url?.absoluteString ?? "")")
    }
}
