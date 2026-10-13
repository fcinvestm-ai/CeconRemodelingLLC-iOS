import SwiftUI
import WebKit
import Foundation

struct ContentView: View {
    var body: some View { ExactPreviewWebView().ignoresSafeArea() }
}

struct ExactPreviewWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.allowsBackForwardNavigationGestures = true

        guard let appHomeURL = Bundle.main.url(forResource: "AppHome", withExtension: "html") else {
            webView.loadHTMLString("<!doctype html><html><body style='margin:0;background:#111827;color:white;font-family:-apple-system;padding:32px'><h2>App content could not be loaded.</h2></body></html>", baseURL: nil)
            return webView
        }
        webView.loadFileURL(appHomeURL, allowingReadAccessTo: Bundle.main.bundleURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
