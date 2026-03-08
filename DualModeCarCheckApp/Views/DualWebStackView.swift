import SwiftUI
import WebKit

struct DualWebStackView: View {
    @State private var topProcessPool = WKProcessPool()
    @State private var bottomProcessPool = WKProcessPool()

    @State private var topIsLoading: Bool = true
    @State private var bottomIsLoading: Bool = true
    @State private var topPageTitle: String = ""
    @State private var bottomPageTitle: String = ""
    @State private var topCurrentURL: String = ""
    @State private var bottomCurrentURL: String = ""

    @State private var topWebView: WKWebView?
    @State private var bottomWebView: WKWebView?

    @State private var splitRatio: CGFloat = 0.45
    @State private var dragStartRatio: CGFloat = 0.45
    @State private var isDragging: Bool = false
    @State private var reloadTrigger: Int = 0

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let topURL = URL(string: "https://joefortunepokies.win/login")!
    private let bottomURL = URL(string: "https://ignitioncasino.lat/login")!

    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > geo.size.height && horizontalSizeClass == .regular
            if isWide {
                landscapeLayout(geo: geo)
            } else {
                portraitLayout(geo: geo)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .top) {
            topToolbar
        }
    }

    private func portraitLayout(geo: GeometryProxy) -> some View {
        let totalHeight = geo.size.height
        let handleHeight: CGFloat = 28
        let topHeight = (totalHeight - handleHeight) * splitRatio
        let bottomHeight = (totalHeight - handleHeight) * (1.0 - splitRatio)

        return VStack(spacing: 0) {
            webPane(
                label: "JOE FORTUNE",
                icon: "suit.spade.fill",
                color: .green,
                url: topURL,
                processPool: topProcessPool,
                isLoading: $topIsLoading,
                pageTitle: $topPageTitle,
                currentURL: $topCurrentURL,
                webViewRef: $topWebView
            )
            .frame(height: topHeight)

            dragHandle(geo: geo, isVertical: false)
                .frame(height: handleHeight)

            webPane(
                label: "IGNITION",
                icon: "flame.fill",
                color: .orange,
                url: bottomURL,
                processPool: bottomProcessPool,
                isLoading: $bottomIsLoading,
                pageTitle: $bottomPageTitle,
                currentURL: $bottomCurrentURL,
                webViewRef: $bottomWebView
            )
            .frame(height: bottomHeight)
        }
    }

    private func landscapeLayout(geo: GeometryProxy) -> some View {
        let totalWidth = geo.size.width
        let handleWidth: CGFloat = 28
        let leftWidth = (totalWidth - handleWidth) * splitRatio
        let rightWidth = (totalWidth - handleWidth) * (1.0 - splitRatio)

        return HStack(spacing: 0) {
            webPane(
                label: "JOE FORTUNE",
                icon: "suit.spade.fill",
                color: .green,
                url: topURL,
                processPool: topProcessPool,
                isLoading: $topIsLoading,
                pageTitle: $topPageTitle,
                currentURL: $topCurrentURL,
                webViewRef: $topWebView
            )
            .frame(width: leftWidth)

            dragHandle(geo: geo, isVertical: true)
                .frame(width: handleWidth)

            webPane(
                label: "IGNITION",
                icon: "flame.fill",
                color: .orange,
                url: bottomURL,
                processPool: bottomProcessPool,
                isLoading: $bottomIsLoading,
                pageTitle: $bottomPageTitle,
                currentURL: $bottomCurrentURL,
                webViewRef: $bottomWebView
            )
            .frame(width: rightWidth)
        }
    }

    private func webPane(
        label: String,
        icon: String,
        color: Color,
        url: URL,
        processPool: WKProcessPool,
        isLoading: Binding<Bool>,
        pageTitle: Binding<String>,
        currentURL: Binding<String>,
        webViewRef: Binding<WKWebView?>
    ) -> some View {
        ZStack(alignment: .top) {
            SplitWebViewRepresentable(
                url: url,
                processPool: processPool,
                isLoading: isLoading,
                pageTitle: pageTitle,
                currentURL: currentURL,
                onWebViewCreated: { wv in
                    webViewRef.wrappedValue = wv
                }
            )
            .id("\(label)-\(reloadTrigger)")

            paneOverlayHeader(
                label: label,
                icon: icon,
                color: color,
                isLoading: isLoading.wrappedValue,
                urlHost: currentURL.wrappedValue
            )
        }
        .clipShape(.rect(cornerRadius: 0))
    }

    private func paneOverlayHeader(label: String, icon: String, color: Color, isLoading: Bool, urlHost: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(color)
                .symbolEffect(.pulse, isActive: isLoading)

            Text(label)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(.white)

            if !urlHost.isEmpty {
                Text(urlHost)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .controlSize(.mini)
                    .tint(color)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color.opacity(0.7))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .allowsHitTesting(false)
    }

    private func dragHandle(geo: GeometryProxy, isVertical: Bool) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemBackground))

            LinearGradient(
                colors: [.green.opacity(isDragging ? 0.4 : 0.15), .orange.opacity(isDragging ? 0.4 : 0.15)],
                startPoint: isVertical ? .top : .leading,
                endPoint: isVertical ? .bottom : .trailing
            )

            RoundedRectangle(cornerRadius: 3)
                .fill(.white.opacity(isDragging ? 0.5 : 0.2))
                .frame(
                    width: isVertical ? 4 : 36,
                    height: isVertical ? 36 : 4
                )
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    if !isDragging {
                        dragStartRatio = splitRatio
                        isDragging = true
                    }
                    let dimension = isVertical ? geo.size.width : geo.size.height
                    let translation = isVertical ? value.translation.width : value.translation.height
                    let delta = translation / dimension
                    splitRatio = (dragStartRatio + delta).clamped(to: 0.25...0.75)
                }
                .onEnded { _ in
                    withAnimation(.spring(duration: 0.3, bounce: 0.1)) {
                        isDragging = false
                    }
                }
        )
        .sensoryFeedback(.selection, trigger: isDragging)
    }

    private var topToolbar: some View {
        HStack(spacing: 8) {
            MainMenuButton()
                .padding(.leading, 0)
                .padding(.bottom, 0)

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(topIsLoading ? .yellow : .green)
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(bottomIsLoading ? .yellow : .orange)
                    .frame(width: 6, height: 6)
            }

            Button {
                reloadBoth()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 11, weight: .bold))
                    Text("RELOAD")
                        .font(.system(size: 9, weight: .heavy, design: .monospaced))
                }
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .medium), trigger: reloadTrigger)

            Button {
                withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                    splitRatio = 0.45
                }
            } label: {
                Image(systemName: "equal")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        )
    }

    private func reloadBoth() {
        reloadTrigger += 1
        topWebView?.reload()
        bottomWebView?.reload()
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
