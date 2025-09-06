//
//  READMEWebViewStyling.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

// swiftlint:disable type_body_length file_length
// This file legitimately exceeds 300 lines because it contains comprehensive
// CSS and JavaScript constants for GitHub Flavored Markdown rendering, including:
// - Complete CSS stylesheet with dark/light theme support
// - GitHub Flavored Markdown styling (tables, code blocks, alerts, etc.)
// - JavaScript for link interception and smooth scrolling
// - Performance optimization and anchor navigation scripts
// The constants are logically grouped and extracted from the main view for maintainability.

/// Centralized styling constants for READMEWebView
enum READMEWebViewStyling {

    // MARK: - CSS Root Variables
    static let cssRootVariables: String = """
    :root {
        /* Enable automatic color scheme detection */
        color-scheme: light dark;

        /* Preserve working font stack */
        --font-family: -apple-system-body;
        --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', monospace;
        --bg-color: transparent;
        --text-color: inherit;
        --link-color: #0066cc;
        --border-color: #e1e4e8;
        --code-bg: #f6f8fa;
        --inline-code-bg: #f6f8fa;
        --blockquote-border: #dfe2e5;
        --table-border: #dfe2e5;
        --hr-color: #eaecef;
    }

    @media (prefers-color-scheme: dark) {
        :root {
            --bg-color: transparent;
            --text-color: inherit;
            --link-color: #58a6ff;
            --border-color: #30363d;
            --code-bg: #161b22;
            --inline-code-bg: #161b22;
            --blockquote-border: #30363d;
            --table-border: #30363d;
            --hr-color: #30363d;
        }
    }
    """

    // MARK: - CSS Base Reset
    static let cssBaseReset: String = """
    * {
        box-sizing: border-box;
    }

    html { -webkit-text-size-adjust: 100%; }
    html, body {
        margin: 0;
        padding: 0;
        background: var(--bg-color);
        color: var(--text-color);
        font-family: var(--font-family);
        font-size: 16px;
        line-height: 1.5;
        -webkit-text-size-adjust: 100%;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        overflow-x: hidden;
        word-wrap: break-word;
    }
    body { font: -apple-system-body; color: -apple-system-label; }
    """

    // MARK: - CSS Typography
    static let cssTypography: String = """
    h1, h2, h3, h4, h5, h6 {
        margin: 16px 0 8px 0;
        font-weight: 600;
        line-height: 1.25;
        color: var(--text-color);
    }

    h1 { font-size: 2em; margin-top: 24px; margin-bottom: 16px; }
    h2 { font-size: 1.5em; margin-top: 20px; margin-bottom: 12px; }
    h3 { font-size: 1.25em; margin-top: 16px; margin-bottom: 8px; }
    h4 { font-size: 1em; margin-top: 12px; margin-bottom: 8px; }
    h5 { font-size: 0.875em; margin-top: 12px; margin-bottom: 8px; }
    h6 { font-size: 0.85em; margin-top: 12px; margin-bottom: 8px; }

    p {
        margin: 8px 0;
        color: var(--text-color);
    }

    a {
        color: var(--link-color);
        text-decoration: none;
    }
    a:hover { text-decoration: underline; }
    """

    // MARK: - CSS Content
    static let cssContent: String = """
    #readme-content {
        padding: 16px;
        max-width: 100%;
        overflow-wrap: break-word;
    }

    /* Headings - Using rem for automatic scaling */
    h1, h2, h3, h4, h5, h6 {
        margin: 1.5rem 0 1rem 0; /* Use rem for spacing */
        font-weight: 600;
        line-height: 1.25;
        color: var(--text-color);
    }

    h1 {
        font-size: 2rem; /* Use rem instead of em for consistent scaling */
        margin-top: 0;
        border-bottom: 1px solid var(--border-color);
        padding-bottom: 0.3rem;
    }
    h2 {
        border-bottom: 1px solid var(--border-color);
        padding-bottom: 0.3rem;
    }
    h3 { font-size: 1.25rem; }
    h4 { font-size: 1rem; }
    h5 { font-size: 0.875rem; }
    h6 { font-size: 0.8125rem; }

    /* Links */
    a {
        color: var(--link-color);
        text-decoration: none;
    }

    /* Lists */
    ul, ol {
        margin: 8px 0;
        padding-left: 2rem;
    }

    li {
        margin: 4px 0;
    }

    /* Blockquotes */
    blockquote {
        margin: 1rem 0;
        padding: 0.5rem 1rem;
        border-left: 4px solid var(--blockquote-border);
        background: var(--code-bg);
        border-radius: 6px;
    }

    /* Horizontal rules */
    hr {
        border: none;
        border-top: 1px solid var(--hr-color);
        margin: 2rem 0;
    }

    /* Images - Let GitLab's HTML positioning work naturally */
    img {
        border-radius: 6px;
        max-width: 100%;  /* Only constrain images that exceed screen width */
        height: auto;
    }

    /* Images in tables should be constrained */
    td img, th img {
        max-width: 100%;
        height: auto;
        vertical-align: middle;
    }

    /* Responsive image containers */
    .image-container img {
        width: 100%;
        height: auto;
        object-fit: contain;
    }
    """

    // MARK: - CSS Code
    static let cssCode: String = """
    /* Code blocks and inline code - Using rem for automatic scaling */
    pre {
        background: var(--code-bg);
        border: 1px solid var(--border-color);
        border-radius: 6px;
        padding: 1rem;
        margin: 1rem 0;
        overflow-x: auto;
        font-family: var(--font-mono);
        font-size: 0.875rem;
        line-height: 1.45;
    }

    code {
        background: var(--inline-code-bg);
        border: 1px solid var(--border-color);
        border-radius: 3px;
        padding: 0.125rem 0.25rem;
        font-family: var(--font-mono);
        font-size: 0.875em;
    }

    pre code {
        background: none;
        border: none;
        padding: 0;
        font-size: inherit;
    }
    """

    // MARK: - CSS Tables
    static let cssTables: String = """
    /* Tables - Using rem for automatic scaling */
    table {
        border-collapse: collapse;
        width: 100%;
        margin: 1rem 0;
        border: 1px solid var(--table-border);
        border-radius: 6px;
        overflow: hidden;
    }

    th, td {
        padding: 0.5rem 0.75rem;
        text-align: left;
        border-bottom: 1px solid var(--table-border);
    }

    th {
        background: var(--code-bg);
        font-weight: 600;
    }

    tr:last-child td {
        border-bottom: none;
    }
    """

    // MARK: - CSS Alerts
    static let cssAlerts: String = """
    /* GitLab alerts/warnings - Using rem for automatic scaling */
    .alert {
        padding: 0.75rem 1rem;
        margin: 1rem 0;
        border: 1px solid var(--border-color);
        border-radius: 6px;
        border-left: 4px solid var(--border-color);
    }

    .alert-info {
        border-left-color: #79c0ff;
        background: rgba(56, 139, 253, 0.1);
    }

    .alert-warning {
        border-left-color: #d29922;
        background: rgba(187, 128, 9, 0.1);
    }

    .alert-danger {
        border-left-color: #cf222e;
        background: rgba(207, 34, 46, 0.1);
    }

    .alert-success {
        border-left-color: #238636;
        background: rgba(35, 134, 54, 0.1);
    }
    """

    // MARK: - CSS Badges
    static let cssBadges: String = """
    /* GitLab badges/labels - Using rem for automatic scaling */
    .badge, .label {
        display: inline-block;
        padding: 0.125rem 0.5rem;
        font-size: 0.75rem;
        font-weight: 500;
        line-height: 1.125rem;
        border-radius: 1rem;
        background: var(--code-bg);
        border: 1px solid var(--border-color);
        color: var(--text-color);
    }

    /* Task lists */
    .task-list-item {
        list-style-type: none;
    }

    .task-list-item input[type="checkbox"] {
        margin-right: 0.5rem;
    }

    /* Details/summary */
    details {
        border: 1px solid var(--border-color);
        border-radius: 6px;
        padding: 0.5rem;
        margin: 1rem 0;
    }

    summary {
        cursor: pointer;
        font-weight: 600;
    }

    /* Strikethrough */
    del {
        text-decoration: line-through;
        opacity: 0.7;
    }

    /* Footnotes */
    .footnote-ref a {
        font-size: 0.75rem;
        vertical-align: super;
    }
    """

    // MARK: - CSS Print
    static let cssPrint: String = """
    /* Print styles */
    @media print {
        body {
            background: white !important;
            color: black !important;
        }

        pre, code {
            background: #f6f8fa !important;
            border: 1px solid #d1d5db !important;
        }

        .alert {
            border: 2px solid #d1d5db !important;
            background: #f9fafb !important;
        }
    }
    """

    // MARK: - JavaScript Link Interception
    static let jsLinkInterception: String = """
    // Link interception
    document.addEventListener('click', function(e) {
        var link = e.target.closest('a');
        if (link && link.href) {
            console.log('Intercepted link click:', link.href);

            // Special handling for anchor links
            if (link.href.indexOf('#') !== -1) {
                console.log('Detected anchor link:', link.href);
                e.preventDefault();
                e.stopPropagation();

                try {
                    window.webkit.messageHandlers.linkTapped.postMessage({
                        url: link.href,
                        text: link.textContent || link.innerText || ''
                    });
                } catch (error) {
                    console.log('Error posting anchor link message:', error);
                }
                return false;
            }

            e.preventDefault();
            e.stopPropagation();
            try {
                window.webkit.messageHandlers.linkTapped.postMessage({
                    url: link.href,
                    text: link.textContent || link.innerText || ''
                });
            } catch (error) {
                console.log('Error posting link message:', error);
            }
            return false;
        }
    }, true);
    """

    // MARK: - JavaScript Smooth Scrolling
    static let jsSmoothScrolling: String = """
        // Smooth scrolling for anchor links
    function scrollToAnchor(anchor) {
        // Try alternative ID formats
        console.log('Element not found for anchor:', anchor, '- trying alternatives');

        // Try with dashes replaced by underscores
        var alt1 = anchor.replace(/-/g, '_');
        element = document.getElementById(alt1);
        if (element) {
            console.log('Found element with underscore format:', alt1);
            element.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'nearest'
            });
            return true;
        }

        // Try with double dashes replaced by single dash
        var alt2 = anchor.replace(/--/g, '-');
        if (alt2 !== anchor) {
            element = document.getElementById(alt2);
            if (element) {
                console.log('Found element with single dash format:', alt2);
                element.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start',
                    inline: 'nearest'
                });
                return true;
            }
        }

        // Try finding any element that contains the anchor text
        var allElements = document.querySelectorAll('[id*="' + anchor + '"]');
        if (allElements.length > 0) {
            console.log('Found elements containing anchor text:', allElements.length);
            allElements[0].scrollIntoView({
                behavior: 'smooth',
                block: 'start',
                inline: 'nearest'
            });
            return true;
        }

        console.log('No element found for anchor:', anchor);
        return false;
    }
    """

    // MARK: - Performance Optimization Script
    static let performanceOptimizationScript: String = """
    (function() {
        // Optimize image loading - lazy load images below the fold
        function optimizeImages() {
            var images = document.querySelectorAll('img[data-src]');
            var viewportHeight = window.innerHeight || document.documentElement.clientHeight;

            images.forEach(function(img) {
                var rect = img.getBoundingClientRect();
                if (rect.top < viewportHeight * 2) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                }
            });
        }

        // Throttle scroll events for better performance
        var scrollTimer;
        function throttledScroll() {
            clearTimeout(scrollTimer);
            scrollTimer = setTimeout(optimizeImages, 100);
        }

        // Optimize layout and rendering
        function optimizeLayout() {
            // Force hardware acceleration for better scrolling
            var body = document.body;
            body.style.transform = 'translateZ(0)';
            body.style.backfaceVisibility = 'hidden';
            body.style.perspective = '1000px';

            // Optimize text rendering
            body.style.textRendering = 'optimizeLegibility';
            body.style.fontSmooth = 'always';
            body.style.webkitFontSmoothing = 'antialiased';
        }

        // Initialize optimizations when DOM is ready
        document.addEventListener('DOMContentLoaded', function() {
            optimizeLayout();
            optimizeImages();
            window.addEventListener('scroll', throttledScroll, { passive: true });
            window.addEventListener('resize', optimizeImages, { passive: true });
        });

        // Clean up on page unload
        window.addEventListener('beforeunload', function() {
            window.removeEventListener('scroll', throttledScroll);
            window.removeEventListener('resize', optimizeImages);
        });
    })();
    """

    // MARK: - Anchor Navigation Script
    static let anchorNavigationScript: String = """
    (function() {
        // Intercept all clicks on anchor links
        document.addEventListener('click', function(e) {
            var link = e.target.closest('a');
            if (link && link.hash && link.hash.startsWith('#')) {
                e.preventDefault();
                var anchor = link.hash.substring(1);
                scrollToAnchor(anchor);
                return false;
            }
        }, true);

        function scrollToAnchor(anchor) {
            var element = document.getElementById(anchor);
            if (element) {
                element.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start',
                    inline: 'nearest'
                });
                // Update URL hash without triggering navigation
                if (window.history.replaceState) {
                    var newUrl = window.location.pathname + window.location.search + '#' + anchor;
                    window.history.replaceState(null, null, newUrl);
                }
                return true; // Success
            }
            return false; // Failure
        }

        // Handle direct hash changes (e.g., from browser back/forward)
        window.addEventListener('hashchange', function() {
            var hash = window.location.hash;
            if (hash && hash.startsWith('#')) {
                var anchor = hash.substring(1);
                scrollToAnchor(anchor);
            }
        });
    })();
    """

    // MARK: - Computed Properties

}
// swiftlint:enable type_body_length file_length
