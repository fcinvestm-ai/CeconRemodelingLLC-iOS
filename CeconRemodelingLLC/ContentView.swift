import SwiftUI
import WebKit
import Foundation

private let generatedAppHTMLBase64 = "PCFkb2N0eXBlIGh0bWw+PGh0bWw+PGJvZHk+PC9ib2R5PjwvaHRtbD4="

struct ContentView: View {
    var body: some View { ExactPreviewWebView().ignoresSafeArea() }
}
struct ExactPreviewWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        let w = WKWebView(frame: .zero, configuration: c)
        w.allowsBackForwardNavigationGestures = true
        if let d = Data(base64Encoded: generatedAppHTMLBase64), let h = String(data: d, encoding: .utf8) { w.loadHTMLString(h, baseURL: nil) }
        return w
    }
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
