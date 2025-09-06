//
//  CodeWebView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  WebView wrapper for displaying code with syntax highlighting
//

import SwiftUI
import WebKit
import GitLabNetwork

struct CodeWebContainer: View {
    let text: String
    let fileName: String
    var lineAnchor: String?

    var body: some View {
        CodeWebView(text: text, fileName: fileName, lineAnchor: lineAnchor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CodeWebView: UIViewRepresentable {
    let text: String
    let fileName: String
    let lineAnchor: String?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        // Security: Disable potentially dangerous features
        config.suppressesIncrementalRendering = true
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()  // Use non-persistent data store
        let controller = WKUserContentController()
        controller.addUserScript(WKUserScript(
            source: CodeWebViewStyling.anchorScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))
        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.scrollsToTop = true
        // Use baseURL from networking config to allow loading of external CSS/JS resources
        let baseURL: URL? = {
            do {
                return try AppNetworkingConfig.loadFromInfoPlist().baseURL
            } catch {
                // Fallback to hardcoded URL if config loading fails
                return URL(string: "https://gitlab.com")
            }
        }()
        webView.loadHTMLString(wrapHTML(buildBodyHTML()), baseURL: baseURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let anchor = normalizedAnchor(lineAnchor), !anchor.isEmpty {
            let javaScript = "window.scrollToLine('" + anchor.replacingOccurrences(of: "'", with: "\\'") + "')"
            webView.evaluateJavaScript(javaScript, completionHandler: nil)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func normalizedAnchor(_ anchor: String?) -> String? {
        guard var anchorText = anchor?.trimmingCharacters(
            in: CharacterSet(charactersIn: "#")),
              !anchorText.isEmpty else { return nil }
        if !anchorText.hasPrefix("L") { anchorText = "L" + anchorText }
        return anchorText
    }

    private func escapeHTML(_ text: String) -> String {
        var result = text.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        return result
    }

    // swiftlint:disable cyclomatic_complexity
    private func languageClass(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "swift": return "language-swift"
        case "m", "mm", "h": return "language-objectivec"
        case "kt", "kts": return "language-kotlin"
        case "java": return "language-java"
        case "js": return "language-javascript"
        case "ts": return "language-typescript"
        case "json": return "language-json"
        case "yml", "yaml": return "language-yaml"
        case "md": return "language-markdown"
        case "py": return "language-python"
        case "rb": return "language-ruby"
        case "go": return "language-go"
        case "rs": return "language-rust"
        case "cpp", "cc", "cxx", "hpp", "hxx", "c": return "language-cpp"
        case "xml", "html", "htm": return "language-xml"
        case "css": return "language-css"
        default: return ""
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func buildBodyHTML() -> String {
        let lines = text.components(separatedBy: "\n")
        let lang = languageClass(for: fileName)
        var gutter = ""
        var code = "<pre class=\"code-pre\"><code class=\"\(lang)\">"
        gutter.reserveCapacity(lines.count * 16)
        code.reserveCapacity(min(4096, text.count + lines.count * 16))
        for (idx, raw) in lines.enumerated() {
            let lineNumber = idx + 1
            let escapedLine = escapeHTML(raw)
            gutter += "<div class=\"ln\"><a href=\"#L\(lineNumber)\">\(lineNumber)</a></div>"
            code += "<span id=\"L\(lineNumber)\" class=\"line\">\(escapedLine)\n</span>"
        }
        code += "</code></pre>"
        return "<div class=\"vscroll\"><div class=\"frame\"><div class=\"gutter\">\(gutter)</div><div id=\"codeScroll\" class=\"code-scroll\">\(code)</div></div></div><div id=\"divider\" class=\"divider\"></div>"
    }

    private func wrapHTML(_ body: String) -> String {
        CodeWebViewStyling.wrapHTML(body)
    }

    final class Coordinator: NSObject {}
}
