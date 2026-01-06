import WebKit
import os.log

class LocalSchemeHandler: NSObject, WKURLSchemeHandler {
    private let logger = OSLog(subsystem: "com.markdownquicklook.app", category: "LocalSchemeHandler")

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else { return }
        os_log("🔵 Start loading resource: %{public}@", log: logger, type: .debug, url.path)

        // Convert local-resource://<path> to file URL
        let fileUrl = URL(fileURLWithPath: url.path)
        
        do {
            // Attempt to read the file directly.
            // Success depends on App Sandbox read permissions for the file location.
            // QuickLook extensions typically have read access to the previewed file,
            // but sibling access depends on OS policy.
            let data = try Data(contentsOf: fileUrl)
            let response = URLResponse(url: url, mimeType: self.mimeType(for: url), expectedContentLength: data.count, textEncodingName: nil)
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
            os_log("🟢 Successfully loaded: %{public}@", log: logger, type: .debug, url.path)
        } catch {
            os_log("🔴 Failed to load resource: %{public}@. Error: %{public}@", log: logger, type: .error, url.path, error.localizedDescription)
            urlSchemeTask.didFailWithError(error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        os_log("Stopped loading: %{public}@", log: logger, type: .debug, urlSchemeTask.request.url?.path ?? "unknown")
    }
    
    private func mimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "svg": return "image/svg+xml"
        case "css": return "text/css"
        case "js": return "application/javascript"
        default: return "application/octet-stream"
        }
    }
}
