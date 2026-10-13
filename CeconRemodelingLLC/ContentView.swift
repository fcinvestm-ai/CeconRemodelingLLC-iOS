import SwiftUI
import WebKit
import Foundation

struct ContentView: View {
    var body: some View { AppBuilderWebView().ignoresSafeArea() }
}

struct AppBuilderWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = UIColor.white
        webView.scrollView.backgroundColor = UIColor.white
        webView.allowsBackForwardNavigationGestures = false
        if #available(iOS 16.4, *) { webView.isInspectable = true }

        if let home = Bundle.main.url(forResource: "AppHome", withExtension: "html") {
            webView.loadFileURL(home, allowingReadAccessTo: Bundle.main.bundleURL)
        } else {
            let diagnostic = "<!doctype html><meta name='viewport' content='width=device-width,initial-scale=1'><body style='font-family:-apple-system;padding:30px;background:white;color:#111'><h2>AppHome.html is missing from this build.</h2><p>Generate a new iOS project from App Builder.</p></body>"
            webView.loadHTMLString(diagnostic, baseURL: nil)
        }
        return webView
    }
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
