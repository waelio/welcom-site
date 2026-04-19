#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v carton >/dev/null 2>&1; then
  echo "carton is required. Install it with: brew install swiftwasm/tap/carton" >&2
  exit 1
fi

carton bundle --product WelcomSite --no-content-hash

for file in Bundle/app.js Bundle/index.js Bundle/intrinsics.js Bundle/*.wasm; do
  if [[ -e "$file" ]]; then
    cp "$file" "$ROOT_DIR/"
  fi
done

for resource_dir in Bundle/*.resources; do
  if [[ -d "$resource_dir" ]]; then
    target_dir="$ROOT_DIR/$(basename "$resource_dir")"
    rm -rf "$target_dir"
    cp -R "$resource_dir" "$target_dir"
  fi
done

echo "Static site assets synced to repository root."
