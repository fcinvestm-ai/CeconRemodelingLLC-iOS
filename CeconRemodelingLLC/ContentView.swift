import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebContainer(urlString: "https://ministry-client-sites.web.app/p/qX34yVpHomVie5UXg88l/")
            .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct WebContainer: UIViewRepresentable {
    let urlString: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url = URL(string: urlString) { webView.load(URLRequest(url: url)) }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url { webView.load(URLRequest(url: url)) }
            return nil
        }
    }
}
