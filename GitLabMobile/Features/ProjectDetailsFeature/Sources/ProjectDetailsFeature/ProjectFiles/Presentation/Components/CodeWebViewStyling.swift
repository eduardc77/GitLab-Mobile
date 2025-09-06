//
//  CodeWebViewStyling.swift
//  ProjectDetailsFeature
//
//  Copyright © 2025 Eliomane. All rights reserved.
//  Licensed under Apache License v2.0. See LICENSE file.
//

// swiftlint:disable function_body_length

import Foundation

/// Centralized styling constants for CodeWebView
public enum CodeWebViewStyling {
    /// Combined CSS for code syntax highlighting and layout
    public static let combinedCSS: String = """
        :root {
          --codePadL: 10px;
          --codePadR: 10px;
          --lh: 1.4;
          --dividerColor: color-mix(in srgb, currentColor 20%, transparent);
        }
        html { font-size: 14px; line-height: var(--lh); }
        body { margin: 0; padding: 0; font-family: -apple-system-body; font-size: 1rem; line-height: var(--lh); }
        .container { display: flex; height: 100vh; overflow: hidden; }
        .gutter {
          flex-shrink: 0;
          width: 40px;
          padding: 10px var(--codePadR) 10px var(--codePadL);
          background-color: var(--codebg);
          color: var(--gutterColor);
          text-align: right;
          overflow: hidden;
          box-sizing: border-box;
          font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
          font-size: 0.875em;
          line-height: var(--lh);
          user-select: none;
        }
        .gutter-line { display: block; line-height: var(--lh); }
        .code-scroll {
          overflow-x: auto;
          overflow-y: hidden;
          padding: 10px var(--codePadR) 10px var(--codePadL);
          background-color: var(--codebg);
          width: 100%;
          box-sizing: border-box;
        }
        .code-pre { margin: 0; }
        .line { display: block; white-space: pre; line-height: var(--lh); }
        /* Dynamic Type-friendly: inherit size from -apple-system-body and switch family to monospace */
        code {
          font: -apple-system-body;
          font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
          font-size: 1em;
          line-height: var(--lh);
        }
        /* Remove theme padding so gutter and code start on the same baseline */
        code.hljs { padding: 0 !important; background: transparent !important; }
        .line:target { background: color-mix(in srgb, currentColor 12%, transparent); }
        .divider {
          position: fixed;
          top: -50vh;
          bottom: -50vh;
          left: 0;
          width: 1px;
          background: var(--dividerColor);
          pointer-events: none;
        }
    """

    /// External stylesheets to load
    public static let externalStylesheets: String = """
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">
    """

    /// External scripts to load
    public static let externalScripts: String = """
        <script defer src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
    """

    /// Combined JavaScript for syntax highlighting and interactions
    public static let combinedJavaScript: String = """
        document.addEventListener('DOMContentLoaded', function(){
          try {
            var el = document.querySelector('code');
            if (el && window.hljs) { window.hljs.highlightElement(el); }
            var sc = document.getElementById('codeScroll');
            var gut = document.querySelector('.gutter');
            if (sc && gut) { sc.addEventListener('scroll', function(){ gut.scrollTop = sc.scrollTop; }, {passive:true}); }
            // Sync background color from highlighted code to gutter and code container
            if (el) {
              var bg = getComputedStyle(el).backgroundColor;
              if (bg && bg !== 'rgba(0, 0, 0, 0)' && bg !== 'transparent') {
                document.documentElement.style.setProperty('--codebg', bg);
                if (gut) gut.style.backgroundColor = bg;
                if (sc) sc.style.backgroundColor = bg;
              }
            }
            // Position the fixed divider at the gutter's trailing edge without hardcoding widths
            var divider = document.getElementById('divider');
            function positionDivider(){
              if (!divider || !gut) return;
              var r = gut.getBoundingClientRect();
              divider.style.left = Math.round(r.right) + 'px';
            }
            positionDivider();
            window.addEventListener('resize', positionDivider, {passive:true});
            if (window.ResizeObserver && gut) {
              var ro = new ResizeObserver(function(){ positionDivider(); });
              ro.observe(gut);
            }
          } catch(e) {}
        });
    """

    /// JavaScript for line scrolling functionality
    public static let anchorScript: String = """
        (function(){
          window.scrollToLine = function(anchor){
            // Try alternative ID formats
            console.log('Element not found for anchor:', anchor, '- trying alternatives');

            // Try with dashes replaced by underscores
            var alt1 = anchor.replace(/-/g, '_');
            var element = document.getElementById(alt1);
            if (element) {
                console.log('Found element with underscore format:', alt1);
                element.scrollIntoView({
                    behavior: 'smooth',
                    block: 'center'
                });
                // Add temporary highlight
                var prev = element.style.backgroundColor;
                element.style.backgroundColor = 'rgba(255, 255, 0, 0.3)';
                setTimeout(function(){ element.style.backgroundColor = prev; }, 2000);
                return;
            }

            // Try with double dashes replaced by single dash
            var alt2 = anchor.replace(/--/g, '-');
            if (alt2 !== anchor) {
                element = document.getElementById(alt2);
                if (element) {
                    console.log('Found element with single dash format:', alt2);
                    element.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center'
                    });
                    // Add temporary highlight
                    var prev = element.style.backgroundColor;
                    element.style.backgroundColor = 'rgba(255, 255, 0, 0.3)';
                    setTimeout(function(){ element.style.backgroundColor = prev; }, 2000);
                    return;
                }
            }

            // Try finding any element that contains the anchor text
            var allElements = document.querySelectorAll('[id*="' + anchor + '"]');
            if (allElements.length > 0) {
                console.log('Found elements containing anchor text:', allElements.length);
                allElements[0].scrollIntoView({
                    behavior: 'smooth',
                    block: 'center'
                });
                // Add temporary highlight
                var prev = allElements[0].style.backgroundColor;
                allElements[0].style.backgroundColor = 'rgba(255, 255, 0, 0.3)';
                setTimeout(function(){ allElements[0].style.backgroundColor = prev; }, 2000);
                return;
            }

            console.log('No element found for anchor:', anchor);
          };
        })();
    """

    // MARK: - HTML Wrapping Function

    /// Wrap code content in complete HTML document
    public static func wrapHTML(_ body: String) -> String {
        """
        <!doctype html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
          <meta charset="utf-8">
          <link rel="preconnect" href="https://cdnjs.cloudflare.com">
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css" media="(prefers-color-scheme: light)"/>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark-dimmed.min.css" media="(prefers-color-scheme: dark)"/>
          \(externalStylesheets)
          <style>
            :root {
                color-scheme: light dark;
                --lh: 1.45;
                --codebg: transparent;
                --dividerColor: rgb(128,128,128);
                --codePadL: 0px;
                --codePadR: 10px;
            }
            html { -webkit-text-size-adjust: 100%; }
            html, body {
                margin: 0;
                padding: 0;
                background: transparent;
                width: 100%;
                overflow: hidden;
            }
            body { font: -apple-system-body; color: inherit; }
            .vscroll {
                overflow-y: auto;
                overflow-x: hidden;
                -webkit-overflow-scrolling: touch;
                height: 100vh;
                width: 100vw;
            }
            .frame {
                display: grid;
                grid-template-columns: max-content 1fr;
                column-gap: 0;
                min-height: 100%;
                width: 100%;
                overflow: hidden;
            }
            .gutter {
                overflow: hidden;
                padding: 10px 0;
                background: var(--codebg);
                font: inherit;
                font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
                -webkit-user-select: none;
                user-select: none;
                -webkit-touch-callout: none;
                touch-action: pan-y;
            }

            .gutter .ln {
                -webkit-user-select: none;
                user-select: none;
                -webkit-touch-callout: none;
                text-align: right;
                padding-right: 0.25em;
                color: rgba(128,128,128,0.8);
                line-height: var(--lh);
            }
            .gutter .ln a {
                -webkit-user-select: none;
                user-select: none;
                -webkit-touch-callout: none;
                color: inherit;
                text-decoration: none;
                display: block;
                padding: 0;
                margin: 0;
            }
            .gutter ::selection { background: transparent; }
            \(combinedCSS)
          </style>
          \(externalScripts)
          <script>
            \(combinedJavaScript)
          </script>
          <script>
            \(anchorScript)
          </script>
        </head>
        <body>
          \(body)
        </body>
        </html>
        """
    }
}
// swiftlint:enable function_body_length
