import SwiftUI
import WebKit

struct MobileModule: Identifiable, Hashable { let id: String; let title: String; let asset: String }

private let appName = "Cecon Remodeling LLC"
private let baseURL = "https://ceconremodelingllc.com"
private let templateName = "icon-dashboard"
private let navigationStyle = "dashboard"
private let homeModule = "store"
private let themeHex = "#234da9"
private let iconScale: CGFloat = 2
private let fontScale: CGFloat = 2
private let cardRadius: CGFloat = 18.0
private let appModules: [MobileModule] = [
        MobileModule(id: "store", title: "Store", asset: "MwbIcon_store"),
        MobileModule(id: "room-designer", title: "Room Designer", asset: "MwbIcon_layout"),
        MobileModule(id: "chat", title: "Chat", asset: "MwbIcon_chat"),
        MobileModule(id: "project-estimator", title: "Project Estimator", asset: "MwbIcon_calculator")
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
            WebContainer(urlString: pageURL(selected)).id(selected)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if ["bottom","floating"].contains(navigationStyle) { bottomNavigation }
        }
        .overlay(alignment: .topLeading) {
            Button { selected = homeModule } label: { Image(systemName: "chevron.left").font(.headline).padding(12).background(.ultraThinMaterial).clipShape(Circle()) }
                .padding(.top, 8).padding(.leading, 10)
        }
        .overlay(alignment: .topTrailing) {
            if navigationStyle == "drawer" {
                Button { showMenu = true } label: { Image(systemName: "line.3.horizontal").font(.title2).padding(10).background(.ultraThinMaterial).clipShape(Circle()) }
                    .padding(.top, 8).padding(.trailing, 10)
            }
        }
        .sheet(isPresented: $showMenu) { drawerMenu }
    }

    private var dashboard: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(appModules) { item in
                        Button { selected = item.id; showMenu = true } label: {
                            VStack(spacing: 12) { Image(item.asset).renderingMode(.template).resizable().scaledToFit().frame(width: 30 * iconScale, height: 30 * iconScale); Text(item.title).font(.system(size: 15 * fontScale)).fontWeight(.semibold).multilineTextAlignment(.center) }
                                .frame(maxWidth: .infinity, minHeight: 110)
                                .background(item.id == homeModule && templateName == "feature-home" ? Color(hex: themeHex) : Color(.secondarySystemBackground))
                                .foregroundStyle(item.id == homeModule && templateName == "feature-home" ? Color.white : Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: cardRadius))
                        }
                    }
                }.padding()
            }
            .navigationTitle(appName)
            .fullScreenCover(isPresented: $showMenu) {
                ZStack(alignment: .topTrailing) {
                    WebContainer(urlString: pageURL(selected)).ignoresSafeArea(.container, edges: .bottom)
                    Button { showMenu = false } label: { Image(systemName: "chevron.left").font(.headline).padding(10).background(.ultraThinMaterial).clipShape(Circle()) }.padding(.top, 8).padding(.trailing, 10)
                }
            }
            .safeAreaInset(edge: .bottom) { if navigationStyle == "dashboard-bottom" { bottomNavigation } }
        }
    }

    private var bottomNavigation: some View {
        let isFloating = navigationStyle == "floating"
        let innerHorizontal: CGFloat = isFloating ? 10 : 2
        let outerHorizontal: CGFloat = isFloating ? 12 : 0
        let outerBottom: CGFloat = isFloating ? 8 : 0
        let navRadius: CGFloat = isFloating ? 20 : 0
        return HStack {
            ForEach(Array(appModules.prefix(5))) { item in
                Button { selected = item.id } label: {
                    VStack(spacing: 3) {
                        Image(item.asset).renderingMode(.template).resizable().scaledToFit().frame(width: 22 * iconScale, height: 22 * iconScale)
                        Text(item.title.replacingOccurrences(of: "Project ", with: "")).font(.system(size: 10 * fontScale)).lineLimit(1)
                    }.frame(maxWidth: .infinity)
                }.foregroundStyle(selected == item.id ? Color(hex: themeHex) : Color.secondary)
            }
        }
        .padding(.top, 7)
        .padding(.horizontal, innerHorizontal)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: navRadius))
        .padding(.horizontal, outerHorizontal)
        .padding(.bottom, outerBottom)
    }

    private var drawerMenu: some View {
        NavigationView { List(appModules) { item in Button { selected = item.id; showMenu = false } label: { Label { Text(item.title) } icon: { Image(item.asset).renderingMode(.template).resizable().scaledToFit().frame(width: 22, height: 22) } } }.navigationTitle(appName).toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { showMenu = false } } } }
    }

    private func module(_ id: String) -> MobileModule { appModules.first(where: { $0.id == id }) ?? appModules.first ?? MobileModule(id: "index", title: "Home", asset: "MwbIcon_home") }
    private func pageURL(_ id: String) -> String {
        guard var parts = URLComponents(string: baseURL) else { return baseURL }
        var q = parts.queryItems ?? []; q.removeAll { $0.name == "page" || $0.name == "mwbApp" }; q.append(URLQueryItem(name: "mwbApp", value: "1")); if id != "index" { q.append(URLQueryItem(name: "page", value: id)) }; parts.queryItems = q; return parts.url?.absoluteString ?? baseURL
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
