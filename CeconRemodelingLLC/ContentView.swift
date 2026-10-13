import SwiftUI
import WebKit
import Foundation

struct ContentView: View {
    var body: some View {
        ExactPreviewWebView()
            .ignoresSafeArea()
            .background(Color.black)
    }
}

struct ExactPreviewWebView: UIViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        let fallbackURLString: String
        private var usedFallback = false

        init(fallbackURLString: String) {
            self.fallbackURLString = fallbackURLString
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loadFallback(webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            loadFallback(webView)
        }

        private func loadFallback(_ webView: WKWebView) {
            guard !usedFallback,
                  let url = URL(string: fallbackURLString),
                  ["https", "http"].contains(url.scheme?.lowercased() ?? "") else { return }
            usedFallback = true
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(fallbackURLString: "https://ceconremodelingllc.com")
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor.black
        webView.scrollView.backgroundColor = UIColor.black
        webView.allowsBackForwardNavigationGestures = true

        if let appHomeURL = Bundle.main.url(forResource: "AppHome", withExtension: "html") {
            webView.loadFileURL(appHomeURL, allowingReadAccessTo: Bundle.main.bundleURL)
        } else if let fallbackURL = URL(string: "https://ceconremodelingllc.com") {
            webView.load(URLRequest(url: fallbackURL))
        } else {
            webView.loadHTMLString("<!doctype html><html><body style='margin:0;background:#111827;color:white;font-family:-apple-system;padding:32px'><h2>App content could not be loaded.</h2></body></html>", baseURL: nil)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
