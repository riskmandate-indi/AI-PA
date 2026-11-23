# Toolchain

Status: tested in the cloud session on 2026-11-23. Works.
Everything runs inside the cloud session. The user runs nothing in a terminal.

## SVG to PNG

- Renderer: headless Chromium through Playwright. Both are pre-installed in the cloud session.
- Script: agents/graphic-design/tools/render.js
- Runs offline. No network calls. No new dependencies.

Command:

    node agents/graphic-design/tools/render.js <in.svg> <out.png> <size-px> [background]

Examples:

    node agents/graphic-design/tools/render.js agents/graphic-design/concepts/1-name/icon.svg agents/graphic-design/concepts/1-name/preview-1024.png 1024
    node agents/graphic-design/tools/render.js agents/graphic-design/concepts/1-name/icon.svg agents/graphic-design/concepts/1-name/preview-60.png 60 "#FAF7F2"

- Without a background the PNG is transparent.
- With a background (hex) the PNG is opaque. Use #FAF7F2 for light and #15131F for dark.

## Test result

- Rendered a test SVG at 1024 x 1024 (transparent) and 60 x 60 (off-white). Both PNGs were valid.
- Test files were temporary and are not in the repo.

## Fonts

- Inter: installed in the cloud session.
- Space Grotesk: not installed in the cloud session.
  - Downloading it is a network call for tooling, not for the app. I will still ask security-vault before fetching it.
  - Fallback: draw the wordmark letters as custom SVG paths. Final logos use outlines anyway, so no live font is needed.

## Other tools available

- ImageMagick (convert): for resizing and contact sheets. Not used for SVG rendering, since Chromium is more accurate.

## Rules

- No font CDNs, no remote images, no analytics in any HTML or SVG output.
- Logo SVGs contain outlines only. No embedded or linked fonts.
