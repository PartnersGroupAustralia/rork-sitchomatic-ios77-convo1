import SwiftUI
import WebKit

struct SplitWebViewRepresentable: UIViewRepresentable {
    let url: URL
    let processPool: WKProcessPool
    @Binding var isLoading: Bool
    @Binding var pageTitle: String
    @Binding var currentURL: String
    var onWebViewCreated: ((WKWebView) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.processPool = processPool
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.isElementFullscreenEnabled = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        context.coordinator.webView = webView
        context.coordinator.startObserving()

        let request = URLRequest(url: url)
        webView.load(request)

        Task { @MainActor in
            onWebViewCreated?(webView)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: SplitWebViewRepresentable
        weak var webView: WKWebView?
        private var titleObservation: NSKeyValueObservation?
        private var urlObservation: NSKeyValueObservation?
        private var loadingObservation: NSKeyValueObservation?

        init(parent: SplitWebViewRepresentable) {
            self.parent = parent
        }

        func startObserving() {
            guard let webView else { return }

            loadingObservation = webView.observe(\.isLoading, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in
                    self?.parent.isLoading = wv.isLoading
                }
            }

            titleObservation = webView.observe(\.title, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in
                    self?.parent.pageTitle = wv.title ?? ""
                }
            }

            urlObservation = webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
                Task { @MainActor in
                    self?.parent.currentURL = wv.url?.host ?? wv.url?.absoluteString ?? ""
                }
            }
        }

        nonisolated func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                parent.isLoading = false
                parent.pageTitle = webView.title ?? ""
                parent.currentURL = webView.url?.host ?? ""
            }
        }

        nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.isLoading = false
            }
        }

        nonisolated func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in
                parent.isLoading = false
            }
        }
    }
}
