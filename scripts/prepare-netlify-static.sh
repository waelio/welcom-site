#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
OUTPUT_DIR="$ROOT_DIR/netlify-static/dist"

copy_matching_entries() {
  pattern="$1"

  for src in "$ROOT_DIR"/$pattern; do
    [ -e "$src" ] || continue

    name=$(basename "$src")
    dest="$OUTPUT_DIR/$name"

    if [ -d "$src" ]; then
      cp -R "$src" "$dest"
    else
      cp "$src" "$dest"
    fi
  done
}

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

copy_matching_entries "*.html"
copy_matching_entries "*.js"
copy_matching_entries "*.css"
copy_matching_entries "*.wasm"
copy_matching_entries "*.map"
copy_matching_entries "*.resources"
copy_matching_entries "icons"

printf 'Prepared static Netlify deploy in %s\n' "$OUTPUT_DIR"