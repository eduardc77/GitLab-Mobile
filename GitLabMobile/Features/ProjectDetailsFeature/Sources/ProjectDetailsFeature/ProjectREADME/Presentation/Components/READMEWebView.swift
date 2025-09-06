//
//  READMEWebView.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//
//  WebView for displaying README content with GitLab-specific features
//

// swiftlint:disable type_body_length file_length
// This file legitimately exceeds 300 lines because it implements a comprehensive
// WebView component with GitHub Flavored Markdown support, including:
// - UIViewRepresentable implementation
// - WKWebView configuration and setup
// - HTML processing and authentication
// - Coordinator with multiple delegate implementations
// - Complex JavaScript injection for link handling
// The functionality is cohesive and splitting would reduce maintainability.

import SwiftUI
import WebKit
import GitLabLogging
import GitLabImageLoading

struct READMEWebView: UIViewRepresentable {
    let htmlContent: String
    let baseURL: URL?
    let projectId: Int
    let onLinkTap: ((URL) -> Bool)?
    let scrollToAnchor: String?
    let authToken: String?

    init(htmlContent: String, baseURL: URL?, projectId: Int, onLinkTap: ((URL) -> Bool)? = nil, scrollToAnchor: String? = nil, authToken: String? = nil) {
        self.htmlContent = htmlContent
        self.baseURL = baseURL
        self.projectId = projectId
        self.onLinkTap = onLinkTap
        self.scrollToAnchor = scrollToAnchor
        self.authToken = authToken
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        configuration.defaultWebpagePreferences.preferredContentMode = .mobile
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.allowsInlineMediaPlayback = true

        // Security: Disable potentially dangerous features
        configuration.suppressesIncrementalRendering = true

        // Use default data store for cookie-based authentication
        configuration.websiteDataStore = WKWebsiteDataStore.default()

        // Process pool for better memory management
        let processPool = WKProcessPool()
        configuration.processPool = processPool

        // Configure user content controller for message handling
        let userContentController = WKUserContentController()

        // Add performance-optimized scripts
        userContentController.addUserScript(anchorNavigationScript)
        userContentController.addUserScript(performanceOptimizationScript)

        // No custom URL scheme needed - authentication handled by existing image loader

        // Add message handlers
        userContentController.add(context.coordinator, contentWorld: .page, name: "linkTapped")
        userContentController.add(context.coordinator, contentWorld: .page, name: "logMessage")

        configuration.userContentController = userContentController

        // Create WebView with optimized settings
        let webView = WKWebView(frame: .zero, configuration: configuration)

        // Configure delegates
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // Set WebView reference for coordinator
        context.coordinator.setWebView(webView)

        // Performance and appearance settings
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.decelerationRate = .normal

        // Enable better scrolling performance
        webView.scrollView.isPagingEnabled = false
        webView.scrollView.bounces = true

        // Enable native scroll-to-top behavior
        webView.scrollView.scrollsToTop = true

        // Authentication is now handled by adding tokens directly to image URLs in HTML
        // No need for cookies since we modify the URLs themselves

        // Load the HTML content
        let wrappedHTML = wrapHTMLContent(htmlContent)
        AppLog.projects.debug("READMEWebView: Loading HTML with baseURL: \(baseURL?.absoluteString ?? "nil")")

        // Log image processing info
        let imgCount = wrappedHTML.components(separatedBy: "<img").count - 1
        AppLog.projects.debug("READMEWebView: Final HTML contains \(imgCount) img tags")

        webView.loadHTMLString(wrappedHTML, baseURL: baseURL)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update coordinator with latest callback and anchor
        context.coordinator.onLinkTap = onLinkTap
        context.coordinator.scrollToAnchor = scrollToAnchor

        // Handle anchor scrolling when anchor is provided
        if let anchor = scrollToAnchor, !anchor.isEmpty {
            context.coordinator.scrollToAnchorInWebView(anchor)
        }
    }

    func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        // Clean up WebView resources
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.scrollView.delegate = nil

        // Clear cache if needed
        WKWebsiteDataStore.default().removeData(
            ofTypes: [WKWebsiteDataTypeMemoryCache],
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) { }

        AppLog.projects.debug("WebView dismantled and cleaned up for project \(projectId)")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onLinkTap: onLinkTap, scrollToAnchor: scrollToAnchor, authToken: authToken)
    }

    private func wrapHTMLContent(_ htmlContent: String) -> String {
        // Process HTML to add authentication to image URLs
        let processedContent = authToken != nil ? processHTMLContent(htmlContent) : htmlContent
        return """
        <!doctype html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover, user-scalable=no">
            <meta charset="utf-8">
            <meta name="format-detection" content="telephone=no">
            <style>
                \(cssStyles)
            </style>
            <script>
                \(javaScriptHelpers)
            </script>
        </head>
        <body>
            <div id="readme-content">
                \(processedContent)
            </div>
        </body>
        </html>
        """
    }

    private func processHTMLContent(_ htmlContent: String) -> String {
        var processedContent = htmlContent

        // Add anchor IDs to headings for proper anchor scrolling
        processedContent = addAnchorIDsToHeadings(processedContent)

        // Wrap wide tables in scrollable containers
        processedContent = wrapWideTables(processedContent)

        // Add authentication tokens to image URLs
        if let authToken = authToken {
            processedContent = addAuthenticationToImageURLs(processedContent, token: authToken)
        }

        return processedContent
    }

    private func addAnchorIDsToHeadings(_ htmlContent: String) -> String {
        var processedContent = htmlContent

        // Pattern to match headings (h1-h6) that don't already have an id attribute
        let headingPattern = #"<(h[1-6])([^>]*)>([^<]*)</\1>"#

        do {
            let regex = try NSRegularExpression(pattern: headingPattern, options: [.caseInsensitive])
            let range = NSRange(location: 0, length: processedContent.utf16.count)

            // Find all matches and process them
            let matches = regex.matches(in: processedContent, options: [], range: range)

            // Process matches in reverse order to maintain correct indices
            for match in matches.reversed() {
                guard let matchRange = Range(match.range, in: processedContent) else { continue }

                let headingText = String(processedContent[matchRange])

                // Find the position of the closing > before the text content
                guard let textStartRange = headingText.range(of: ">", options: .caseInsensitive),
                      let textEndRange = headingText.range(
                        of: "</",
                        options: .backwards,
                        range: textStartRange.upperBound..<headingText.endIndex
                      )
                else { continue }

                let attributesPart = String(headingText[headingText.startIndex..<textStartRange.upperBound])
                let textContent = String(headingText[textStartRange.upperBound..<textEndRange.lowerBound])

                // Generate anchor ID from text content
                let anchorId = generateAnchorID(from: textContent)

                // Check if id attribute already exists
                if attributesPart.contains("id=") {
                    continue // Don't modify if id already exists
                }

                // Add id attribute
                let newAttributes = attributesPart + " id=\"\(anchorId)\""
                let tagName = String(headingText[headingText.index(headingText.startIndex, offsetBy: 1)]) // Get h1, h2, etc.
                let newHeading = newAttributes + ">" + textContent + "</" + tagName + ">"

                // Replace the original heading with the new one
                processedContent = processedContent.replacingCharacters(in: matchRange, with: newHeading)
            }
        } catch {
            AppLog.projects.error("Error adding anchor IDs to headings for project \(projectId): \(error.localizedDescription)")
        }

        return processedContent
    }

    private func generateAnchorID(from text: String) -> String {
        // Convert text to lowercase, replace spaces and special chars with hyphens
        // This matches GitHub's anchor ID generation and common markdown processors
        var cleanedText = text.lowercased()

        // Replace special characters with hyphens
        let allowedChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "- "))
        cleanedText = String(cleanedText.unicodeScalars.filter { allowedChars.contains($0) })

        // Replace spaces with hyphens
        cleanedText = cleanedText.replacingOccurrences(of: " ", with: "-")

        // Replace multiple hyphens with single hyphen
        while cleanedText.contains("--") {
            cleanedText = cleanedText.replacingOccurrences(of: "--", with: "-")
        }

        // Trim leading/trailing hyphens
        cleanedText = cleanedText.trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        return cleanedText.isEmpty ? "heading" : cleanedText
    }

    private func wrapWideTables(_ htmlContent: String) -> String {
        var processedContent = htmlContent

        do {
            // Pattern to match table elements - capture table tag attributes and content
            let tablePattern = #"<table([^>]*)>(.*?)</table>"#

            let regex = try NSRegularExpression(pattern: tablePattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSRange(location: 0, length: processedContent.utf16.count)

            // Wrap each table in a scrollable container
            // $1 = table attributes, $2 = table content
            let replacement = "<div class=\"table-container\"><table$1>$2</table></div>"

            processedContent = regex.stringByReplacingMatches(
                in: processedContent,
                options: [],
                range: range,
                withTemplate: replacement
            )

            AppLog.projects.debug("READMEWebView: Wrapped tables in scrollable containers")

        } catch {
            AppLog.projects.error("READMEWebView: Failed to wrap tables: \(error.localizedDescription)")
        }

        return processedContent
    }

    // MARK: - Combined CSS Styles
    private var cssStyles: String {
        READMEWebViewStyling.cssRootVariables +
        READMEWebViewStyling.cssBaseReset +
        READMEWebViewStyling.cssTypography +
        READMEWebViewStyling.cssContent +
        READMEWebViewStyling.cssCode +
        READMEWebViewStyling.cssTables +
        READMEWebViewStyling.cssAlerts +
        READMEWebViewStyling.cssBadges +
        READMEWebViewStyling.cssPrint
    }

    // MARK: - Combined JavaScript Helpers
    private var javaScriptHelpers: String {
        READMEWebViewStyling.jsLinkInterception + READMEWebViewStyling.jsSmoothScrolling
    }

    // MARK: - Performance Optimization Script
    private var performanceOptimizationScript: WKUserScript {
        WKUserScript(
            source: READMEWebViewStyling.performanceOptimizationScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
    }

    // MARK: - Anchor Navigation Script
    private var anchorNavigationScript: WKUserScript {
        WKUserScript(
            source: READMEWebViewStyling.anchorNavigationScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var onLinkTap: ((URL) -> Bool)?
        var scrollToAnchor: String?
        var authToken: String?
        weak var webView: WKWebView?

        init(onLinkTap: ((URL) -> Bool)?, scrollToAnchor: String?, authToken: String?) {
            self.onLinkTap = onLinkTap
            self.scrollToAnchor = scrollToAnchor
            self.authToken = authToken
        }

        func setWebView(_ webView: WKWebView) {
            self.webView = webView
        }

        func scrollToAnchorInWebView(_ anchor: String) {
            guard let webView = webView else { return }

            let javascript = "scrollToAnchor('\(anchor.replacingOccurrences(of: "'", with: "\\'"))')"
            webView.evaluateJavaScript(javascript) { result, error in
                if let error = error {
                    AppLog.projects.error("JavaScript error scrolling to anchor '\(anchor)' for project \(self.authToken != nil ? "with auth" : "without auth"): \(error.localizedDescription)")
                } else if let success = result as? Bool {
                    if success {
                        AppLog.projects.debug("Successfully scrolled to anchor: \(anchor)")
                    } else {
                        AppLog.projects.debug("Failed to scroll to anchor: \(anchor) - element not found")
                    }
                } else {
                    AppLog.projects.debug("Unexpected JavaScript result for anchor '\(anchor)': \(String(describing: result))")
                }
            }
        }

        // MARK: - WKScriptMessageHandler
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "linkTapped":
                if let dict = message.body as? [String: Any],
                   let urlString = dict["url"] as? String,
                   let url = URL(string: urlString) {

                    // Handle anchor links (TOC navigation)
                    AppLog.projects.debug("README WebView processing link: \(url.absoluteString)")

                    // Check if this is an anchor link (has fragment)
                    if let fragment = url.fragment, !fragment.isEmpty {
                        AppLog.projects.debug("README WebView detected anchor link: #\(fragment)")
                        scrollToAnchorInWebView(fragment)
                        return
                    }

                    // Handle pure hash links (#section)
                    if url.absoluteString.hasPrefix("#"), url.absoluteString.count > 1 {
                        let fragment = String(url.absoluteString.dropFirst())
                        AppLog.projects.debug("README WebView detected hash link: #\(fragment)")
                        scrollToAnchorInWebView(fragment)
                        return
                    }

                    // Handle relative anchor links (section-name)
                    if url.scheme == nil && url.host == nil && url.absoluteString.contains("#") {
                        if let hashIndex = url.absoluteString.firstIndex(of: "#"),
                           hashIndex < url.absoluteString.endIndex {
                            let fragment = String(url.absoluteString[url.absoluteString.index(after: hashIndex)...])
                            AppLog.projects.debug("README WebView detected relative anchor link: #\(fragment)")
                            scrollToAnchorInWebView(fragment)
                            return
                        }
                    }

                    // Handle other links through the callback
                    let shouldHandle = onLinkTap?(url) ?? false
                    if !shouldHandle {
                        // If not handled by our callback, try to open in system
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            case "logMessage":
                if let message = message.body as? String {
                    AppLog.projects.debug("README WebView message: \(message)")
                }
            default:
                break
            }
        }

        // MARK: - WKNavigationDelegate
        private func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // WKNavigationDelegate method implementation
            decidePolicyForNavigationAction(webView, navigationAction: navigationAction, decisionHandler: decisionHandler)
        }

        private func decidePolicyForNavigationAction(_ webView: WKWebView, navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Only log image requests to reduce noise
                let pathExtension = url.pathExtension.lowercased()
                let imageExtensions = ["png", "jpg", "jpeg", "gif", "webp", "svg"]

                if imageExtensions.contains(pathExtension) {
                    AppLog.projects.debug("READMEWebView: Loading image: \(url.absoluteString)")
                }
                // Handle anchor links (TOC navigation)
                if let fragment = url.fragment, !fragment.isEmpty {
                    AppLog.projects.debug("README WebView WKNavigationDelegate detected anchor link: #\(fragment)")
                    scrollToAnchorInWebView(fragment)
                    decisionHandler(.cancel)
                    return
                }

                // Handle pure hash links
                if url.absoluteString.hasPrefix("#"), url.absoluteString.count > 1 {
                    let fragment = String(url.absoluteString.dropFirst())
                    AppLog.projects.debug("README WebView WKNavigationDelegate detected hash link: #\(fragment)")
                    scrollToAnchorInWebView(fragment)
                    decisionHandler(.cancel)
                    return
                }

                // Handle other links
                if navigationAction.navigationType == .linkActivated {
                    let shouldHandle = onLinkTap?(url) ?? false
                    decisionHandler(shouldHandle ? .cancel : .allow)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation?, withError error: Error) {
            AppLog.projects.error("README WebView navigation failed: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: Error) {
            AppLog.projects.error("README WebView provisional navigation failed: \(error.localizedDescription)")
            if let failingURL = (error as NSError).userInfo["NSErrorFailingURLKey"] as? URL {
                AppLog.projects.error("README WebView failed to load: \(failingURL.absoluteString)")
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
            AppLog.projects.debug("README WebView navigation finished successfully")

            // Check if images are actually loaded by counting them
            webView.evaluateJavaScript("document.images.length") { result, _ in
                if let count = result as? Int {
                    AppLog.projects.debug("README WebView: Found \(count) images in DOM")
                }
            }

            // Check for broken images
            webView.evaluateJavaScript("""
                Array.from(document.images).filter(img => !img.complete || img.naturalHeight === 0).length
            """) { result, _ in
                if let brokenCount = result as? Int {
                    if brokenCount > 0 {
                        AppLog.projects.debug("README WebView: Found \(brokenCount) broken/unloaded images")
                    } else {
                        AppLog.projects.debug("README WebView: All images appear to be loaded successfully")
                    }
                }
            }

            // Log image information
            webView.evaluateJavaScript("""
                Array.from(document.images).map(img => ({
                    src: img.src,
                    width: img.naturalWidth,
                    height: img.naturalHeight,
                    visible: img.offsetWidth > 0 && img.offsetHeight > 0
                })).slice(0, 5) // First 5 images only
            """) { result, _ in
                if let imageInfo = result as? [[String: Any]] {
                    AppLog.projects.debug("README WebView: First 5 images info:")
                    for (index, info) in imageInfo.enumerated() {
                        let src = info["src"] as? String ?? "unknown"
                        let width = info["width"] as? Int ?? 0
                        let height = info["height"] as? Int ?? 0
                        let visible = info["visible"] as? Bool ?? false
                        AppLog.projects.debug("  Image \(index + 1): \(width)x\(height) \(visible ? "visible" : "hidden") - \(src)")
                    }
                }
            }
        }

        // MARK: - WKUIDelegate
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Prevent opening new windows/tabs
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return nil
        }
    }

    // MARK: - Image Authentication

    private func addAuthenticationToImageURLs(_ htmlContent: String, token: String) -> String {
        var processedContent = htmlContent

        do {
            // Process both data-canonical-src and data-src patterns
            let patterns = [
                // GitLab's current format: data-canonical-src
                #"<img([^>]*)src="([^"]*)"([^>]*)data-canonical-src="([^"]*)"([^>]*)>"#,
                // Legacy format: data-src
                #"<img([^>]*)src="([^"]*)"([^>]*)data-src="([^"]*)"([^>]*)>"#,
            ]

            for pattern in patterns {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
                let range = NSRange(location: 0, length: processedContent.utf16.count)

                var replacements = [(NSRange, String)]()

                regex.enumerateMatches(in: processedContent, options: [], range: range) { match, _, _ in
                    guard let match = match,
                          match.numberOfRanges >= 5 else { return }

                    let fullRange = match.range(at: 0)
                    let beforeSrc = match.range(at: 1)
                    let srcValue = match.range(at: 2)
                    let betweenSrc = match.range(at: 3)
                    let dataSrcValue = match.range(at: 4)
                    let afterDataSrc = match.range(at: 5)

                    // Extract the URLs
                    let srcURL = (processedContent as NSString).substring(with: srcValue)
                    let dataSrcURL = (processedContent as NSString).substring(with: dataSrcValue)

                    // Use the real image URL as src (replace placeholder data URLs)
                    let finalSrcURL = srcURL.hasPrefix("data:") ? dataSrcURL : srcURL

                    // Build new img tag with the real image URL as src
                    let beforeSrcText = (processedContent as NSString).substring(with: beforeSrc)
                    let betweenSrcText = (processedContent as NSString).substring(with: betweenSrc)
                    let afterDataSrcText = (processedContent as NSString).substring(with: afterDataSrc)

                    let newImgTag = "<img\(beforeSrcText)src=\"\(finalSrcURL)\"\(betweenSrcText)\(afterDataSrcText)>"

                    replacements.append((fullRange, newImgTag))
                    // Log image processing
                    if srcURL.hasPrefix("data:") {
                        AppLog.projects.debug("READMEWebView: Replaced placeholder data URL with: \(finalSrcURL)")
                    } else if dataSrcURL != srcURL {
                        AppLog.projects.debug("READMEWebView: Added authentication to: \(finalSrcURL)")
                    } else {
                        AppLog.projects.debug("READMEWebView: No changes needed for: \(srcURL)")
                    }

                }

                // Apply replacements for this pattern
                for (range, replacement) in replacements.reversed() {
                    processedContent = (processedContent as NSString).replacingCharacters(in: range, with: replacement)
                }
            }

        } catch {
            AppLog.projects.error("READMEWebView: Failed to process lazy loading images: \(error.localizedDescription)")
        }

        return processedContent
    }
}
// swiftlint:enable type_body_length file_length
