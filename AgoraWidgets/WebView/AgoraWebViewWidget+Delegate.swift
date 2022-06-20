//
//  AgoraWebViewWidget+Delegate.swift
//  AgoraWidgets
//
//  Created by LYY on 2022/6/8.
//

import Foundation

extension AgoraWebViewWidget: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        didCommit navigation: WKNavigation!) {
        webViewState = .committed
    }
    public func webView(_ webView: WKWebView,
                        didFinish navigation: WKNavigation!) {
        webViewState = .finished
    }
}

extension AgoraWebViewWidget: WKUIDelegate {
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame,
           !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension AgoraWebViewWidget: AgoraWebViewContentViewDelegate {
    func onClickRefresh() {
        contentView.refreshWebView()
    }
    
    func onClickScale() {
        sendMessage(signal: .scale)
    }
    
    func onClickClose() {
        sendMessage(signal: .close)
    }
}
