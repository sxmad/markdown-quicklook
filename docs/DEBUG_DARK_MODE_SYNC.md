# Priority 4: Perfect Dark Mode Sync

**Status**: Completed
**Date**: 2026-01-07

## Implementation Details

### 1. Web Layer (`web-renderer`)
- **Combined CSS**: Replaced separate light/dark CSS files for Highlight.js with a single `highlight-adaptive.css` using `@media (prefers-color-scheme: dark)`. This ensures instant theme switching without JS intervention for code blocks.
- **Theme Awareness**: Updated `window.renderMarkdown` signature to accept a `theme` parameter (`'light' | 'dark' | 'system'`).
- **Mermaid Sync**: Explicitly sets the Mermaid theme based on the passed `theme` parameter or system preference, preventing "white flash" or mismatched diagrams.

### 2. Swift Host (`MarkdownWebView.swift`)
- **Theme Injection**: Now detects the `WKWebView.effectiveAppearance` and passes an explicit `"theme": "light" | "dark"` value to the JS renderer.

### 3. Swift Extension (`PreviewViewController.swift`)
- **Theme Injection**: Similarly detects `view.effectiveAppearance` and passes the theme to the renderer during QuickLook.

## Verification
- **Build**: Successfully rebuilt web-renderer and macOS app.
- **Code Check**: Verified `theme` parameter passing in all 3 relevant files using grep.

## Next Steps
- Proceed to **Priority 5: Rendering Stability** (Mermaid FOUC) or **Priority 6: State Persistence**.
