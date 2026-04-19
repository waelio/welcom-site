# WelcomSite

A SwiftWasm + Tokamak site for WelcomTalk, now with a live browser-session beta on the home page.

## What changed

- Replaced the old hand-authored website with a Swift Package executable target named `WelcomSite`.
- Added a local SwiftPM dependency on the parent app at `../WelcomTalk`.
- Exposed a reusable `WelcomShared` library from the parent app so the site can render real shared models and a portable shared view model.
- Kept `index.html`, `privacy.html`, and `terms.html` as human-readable fallback pages for App Store review and no-JavaScript access.
- Added `scripts/build-site.sh` to produce the WebAssembly bundle and sync the generated assets into the repository root for static hosting.
- Added a smart browser-session beta that can start a session, share an invite link, and let a guest join through a lightweight relay.

## Project structure

- `Package.swift` — Swift Package manifest for the Tokamak app.
- `Sources/WelcomSiteCore/` — shared site content models and page view models.
- `Sources/WelcomSite/` — Tokamak app entrypoint, browser helpers, smart session store, and UI views.
- `scripts/build-site.sh` — production bundle sync script.
- `index.html`, `privacy.html`, `terms.html` — deploy-time shell pages and graceful fallbacks.

## Development

Install `carton` locally, then run the Tokamak dev server for the home page experience:

```bash
brew install swiftwasm/tap/carton
carton dev --product WelcomSite
```

The browser beta currently talks to `wss://waelio-messaging.onrender.com` by default. You can override that in the page shell by setting `window.__WELCOM_WS_URL__` before `app.js` loads.

## Production build

Build the WebAssembly bundle and sync generated assets into the repository root:

```bash
./scripts/build-site.sh
```

That script copies the generated `app.js`, `index.js`, `intrinsics.js`, `.wasm`, and any runtime resource folders into the repository root so GitHub Pages or another static host can serve them directly.

## Shared package note

The parent app now exposes a local Swift package product named `WelcomShared` from `../WelcomTalk`. The web site currently consumes:

- `Session`
- `Note`
- `LogEntry`
- `ModificationRequest`
- `SessionRating`
- `User`
- `ScheduledMeeting`
- `SessionSummaryViewModel`

This keeps the shared domain layer portable and leaves Apple-only services (speech, EventKit, Multipeer, etc.) inside the iOS app target where they belong.

## Smart-site direction

If you want to make the website more capable over time, the cleanest next step is a tiny relay service written in TypeScript or Go so browser sessions can be self-hosted instead of relying on the current default relay endpoint.
