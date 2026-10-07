import SwiftUI
import WebKit

struct MobileModule: Identifiable, Hashable { let id: String; let title: String; let symbol: String }

private let appName = "Cecon Remodeling LLC"
private let baseURL = "https://ceconremodelingllc.com"
private let templateName = "floating-dock"
private let navigationStyle = "floating"
private let homeModule = "store"
private let themeHex = "#234da9"
private let appModules: [MobileModule] = [
        MobileModule(id: "store", title: "Store", symbol: "bag.fill"),
        MobileModule(id: "room-designer", title: "Room Designer", symbol: "square.3.layers.3d"),
        MobileModule(id: "chat", title: "Chat", symbol: "message.fill"),
        MobileModule(id: "project-estimator", title: "Project Estimator", symbol: "sum")
]

struct ContentView: View {
    @State private var selected = homeModule
    @State private var showMenu = false

    var body: some View {
        Group {
            if templateName == "icon-dashboard" || templateName == "dashboard-nav" || navigationStyle == "dashboard" || navigationStyle == "dashboard-bottom" {
                dashboard
            } else {
                appContent
            }
        }
        .tint(Color(hex: themeHex))
    }

    private var appContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text(appName).font(.headline).lineLimit(1)
                Spacer()
                if navigationStyle == "drawer" {
                    Button { showMenu = true } label: { Image(systemName: "line.3.horizontal").font(.title2) }
                }
            }.padding(.horizontal, 16).frame(height: 52).background(.background).overlay(alignment: .bottom) { Divider() }
            WebContainer(urlString: pageURL(selected)).id(selected)
            if ["bottom","floating"].contains(navigationStyle) { bottomNavigation }
        }
        .sheet(isPresented: $showMenu) { drawerMenu }
    }

    private var dashboard: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(appModules) { item in
                        Button { selected = item.id; showMenu = true } label: {
                            VStack(spacing: 12) { Image(systemName: item.symbol).font(.system(size: 28)); Text(item.title).font(.subheadline).fontWeight(.semibold).multilineTextAlignment(.center) }
                                .frame(maxWidth: .infinity, minHeight: (templateName == "feature-home" && item.id == homeModule) ? 145 : 110)
                                .background(item.id == homeModule && templateName == "feature-home" ? Color(hex: themeHex) : Color(.secondarySystemBackground))
                                .foregroundStyle(item.id == homeModule && templateName == "feature-home" ? Color.white : Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }.padding()
            }
            .navigationTitle(appName)
            .fullScreenCover(isPresented: $showMenu) {
                VStack(spacing: 0) { HStack { Button("Done") { showMenu = false }; Spacer(); Text(module(selected).title).fontWeight(.semibold); Spacer(); Color.clear.frame(width: 44) }.padding(); Divider(); WebContainer(urlString: pageURL(selected)) }
            }
            .safeAreaInset(edge: .bottom) { if navigationStyle == "dashboard-bottom" { bottomNavigation } }
        }
    }

    private var bottomNavigation: some View {
        HStack {
            ForEach(Array(appModules.prefix(5))) { item in
                Button { selected = item.id } label: { VStack(spacing: 3) { Image(systemName: item.symbol); Text(item.title.replacingOccurrences(of: "Project ", with: "")).font(.caption2).lineLimit(1) }.frame(maxWidth: .infinity) }.foregroundStyle(selected == item.id ? Color(hex: themeHex) : .secondary)
            }
        }.padding(.top, 7).padding(.horizontal, navigationStyle == "floating" ? 10 : 2).padding(.bottom, 4).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: navigationStyle == "floating" ? 20 : 0))
          .padding(.horizontal, navigationStyle == "floating" ? 12 : 0).padding(.bottom, navigationStyle == "floating" ? 8 : 0)
    }

    private var drawerMenu: some View {
        NavigationView { List(appModules) { item in Button { selected = item.id; showMenu = false } label: { Label(item.title, systemImage: item.symbol) } }.navigationTitle(appName).toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { showMenu = false } } } }
    }

    private func module(_ id: String) -> MobileModule { appModules.first(where: { $0.id == id }) ?? appModules.first ?? MobileModule(id: "index", title: "Home", symbol: "house.fill") }
    private func pageURL(_ id: String) -> String {
        guard var parts = URLComponents(string: baseURL) else { return baseURL }
        var q = parts.queryItems ?? []; q.removeAll { $0.name == "page" }; if id != "index" { q.append(URLQueryItem(name: "page", value: id)) }; parts.queryItems = q.isEmpty ? nil : q; return parts.url?.absoluteString ?? baseURL
    }
}

struct WebContainer: UIViewRepresentable {
    let urlString: String
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> WKWebView { let c = WKWebViewConfiguration(); c.allowsInlineMediaPlayback = true; c.mediaTypesRequiringUserActionForPlayback = []; let w = WKWebView(frame: .zero, configuration: c); w.navigationDelegate = context.coordinator; w.uiDelegate = context.coordinator; w.allowsBackForwardNavigationGestures = true; if let u=URL(string:urlString){w.load(URLRequest(url:u))}; return w }
    func updateUIView(_ webView: WKWebView, context: Context) {}
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate { func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? { if navigationAction.targetFrame == nil, let u=navigationAction.request.url { webView.load(URLRequest(url:u)) }; return nil } }
}

extension Color { init(hex: String) { var s=hex.trimmingCharacters(in:.whitespacesAndNewlines); if s.hasPrefix("#"){s.removeFirst()}; var n:UInt64=0; Scanner(string:s).scanHexInt64(&n); self.init(.sRGB, red:Double((n>>16)&255)/255, green:Double((n>>8)&255)/255, blue:Double(n&255)/255, opacity:1) } }
