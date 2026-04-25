# Netlify deploy base

This directory exists only so Netlify can use it as the build base.

Why:

- Netlify installs dependencies from the configured base directory before it runs the build command.
- Keeping the base at the repository root makes Netlify detect `Package.swift` and try to install Swift.
- This repo deploys committed static files instead, so the deploy base must stay separate from the Swift package root.

During deploys, `../scripts/prepare-netlify-static.sh` copies the public static files from the repository root into `dist/`, and Netlify publishes that folder.