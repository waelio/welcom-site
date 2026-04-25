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

For the fastest local start, use `pnpm` to run the static/dev shell:

```bash
pnpm install
pnpm dev
```

That launches a local Vite server on `http://127.0.0.1:4173/index.html` and opens the site automatically.

If you want to experiment with the SwiftWasm/Tokamak path directly, the older `carton` flow is still in the repo, but it is currently less reliable than `pnpm dev` on this machine.

The optional WebAssembly build now reads its preferred SwiftWasm version from `scripts/swiftwasm-version.txt`. The build script writes a temporary root `.swift-version` only while `carton` is running so static hosts do not try to install SwiftWasm during deploy setup.

The browser beta currently talks to `wss://waelio-messaging.onrender.com` by default. You can override that in the page shell by setting `window.__WELCOM_WS_URL__` before `app.js` loads.

## Production build

Build the WebAssembly bundle and sync generated assets into the repository root:

```bash
./scripts/build-site.sh
```

That script copies the generated `app.js`, `index.js`, `intrinsics.js`, `.wasm`, and any runtime resource folders into the repository root so GitHub Pages or another static host can serve them directly.

For Netlify, this repository is configured as a static deploy with a deploy-only base directory at `netlify-static/`. Netlify installs dependencies and runs the build command from that folder, which keeps the root `Package.swift` from triggering an unwanted Swift install during deploy setup.

The deploy command runs `scripts/prepare-netlify-static.sh`, which copies the committed root HTML, JavaScript, icons, and any optional runtime assets into `netlify-static/dist/` for publishing. That generated folder is ignored in git.

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
