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

    static func open(_ url: String) {
        #if os(WASI)
        if let location = JSObject.global.location.object {
            location["href"] = .string(url)
        }
        #endif
    }
}
