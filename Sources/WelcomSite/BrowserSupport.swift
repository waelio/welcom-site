import Foundation
import WelcomSiteCore

#if os(WASI)
import JavaScriptKit
#endif

enum BrowserSupport {
    static func currentRoute() -> SiteRoute {
        #if os(WASI)
        if let rawRoute = JSObject.global["__WELCOM_PAGE__"].string,
           let route = SiteRoute(rawValue: rawRoute) {
            return route
        }

        if let pathname = JSObject.global.location.object?["pathname"].string {
            if pathname.contains("privacy") {
                return .privacy
            }
            if pathname.contains("terms") {
                return .terms
            }
        }
        #endif

        return .home
    }

    static func currentJoinCode() -> String? {
        #if os(WASI)
        guard let search = JSObject.global.location.object?["search"].string,
              !search.isEmpty else {
            return nil
        }

        for pair in search.dropFirst().split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            guard parts[0].lowercased() == "join" else { continue }

            let decoded = parts[1].replacingOccurrences(of: "%20", with: " ")
            let trimmed = decoded.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            return trimmed.isEmpty ? nil : trimmed
        }
        #endif

        return nil
    }

    static func currentRelayURL() -> String {
        #if os(WASI)
        if let configured = JSObject.global["__WELCOM_WS_URL__"].string,
           !configured.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return configured
        }
        #endif

        return "wss://waelio-messaging.onrender.com"
    }

    static func markAppReady() {
        #if os(WASI)
        guard let document = JSObject.global.document.object,
              let body = document.body.object else { return }

        let existingClassName = body["className"].string ?? ""
        if existingClassName.contains("wasm-ready") {
            return
        }

        let newClassName = existingClassName.isEmpty
            ? "wasm-ready"
            : "\(existingClassName) wasm-ready"
        body["className"] = .string(newClassName)
        #endif
    }

    static func navigate(to route: SiteRoute) {
        open(route.fileName)
    }

    static func inviteURL(for sessionCode: String) -> String {
        let normalizedCode = sessionCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        #if os(WASI)
        guard let location = JSObject.global.location.object else {
            return "index.html?join=\(normalizedCode)"
        }

        let origin = location["origin"].string ?? ""
        let pathname = location["pathname"].string ?? "/index.html"
        let homePath: String

        if pathname.contains("privacy") {
            homePath = pathname.replacingOccurrences(of: "privacy.html", with: "index.html")
        } else if pathname.contains("terms") {
            homePath = pathname.replacingOccurrences(of: "terms.html", with: "index.html")
        } else if pathname.hasSuffix("/") {
            homePath = pathname + "index.html"
        } else if pathname.hasSuffix("index.html") {
            homePath = pathname
        } else {
            homePath = "/index.html"
        }

        return "\(origin)\(homePath)?join=\(normalizedCode)"
        #else
        return "index.html?join=\(normalizedCode)"
        #endif
    }

    static func copyToClipboard(_ value: String) {
        #if os(WASI)
        guard let clipboard = JSObject.global.navigator.object?["clipboard"].object,
              let writeText = clipboard["writeText"].function else {
            return
        }

        _ = writeText(value)
        #endif
    }

    static func open(_ url: String) {
        #if os(WASI)
        if let location = JSObject.global.location.object {
            location["href"] = .string(url)
        }
        #endif
    }
}
