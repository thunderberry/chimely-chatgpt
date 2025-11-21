# Chimely ChatGPT Edition Starter

This folder is a self-contained starting point for rebuilding Chimely as a ChatGPT App using the ChatGPT Apps SDK. It captures the visual DNA of the iOS timer, outlines the experience goals, and provides SwiftUI reference code to recreate the main timer UI with web-native technologies.

## What's inside
- **docs/** — planning materials, scope notes, and next steps for the ChatGPT App conversion.
- **reference/** — SwiftUI reference code extracted from the current iOS timer to guide the web implementation.
- **manifest-template.json** — a starter ChatGPT Apps SDK manifest pre-populated with Chimely-specific metadata and placeholders for tools/endpoints.

## How to use this folder in a new repo
1. Copy the `chimely-chatgpt` folder into a fresh repository and treat it as the project root.
2. Update `manifest-template.json` with your production URLs and tool schemas as you flesh out the ChatGPT App.
3. Follow `docs/plan.md` to scaffold the web timer UI, data flow, and chime logic.
4. Use the SwiftUI code in `reference/TimerReferenceViews.swift` as a visual and behavioral guide when implementing the timer with Canvas/SVG and CSS animations.
5. Track open questions and iterative findings in `docs/notes.md` as you adapt the experience.

## Guiding principles for the ChatGPT App
- Preserve Chimely's calm, concentric ring aesthetic while adapting controls to the ChatGPT Apps SDK UI surface.
- Keep the timer model generic: accept flexible constraints (e.g., timeboxing, habit streaks) and pluggable chime patterns.
- Favor accessibility: ensure keyboard operability, clear focus states, high contrast, and ARIA labels for controls and progress indicators.
- Ship incrementally: start with the core timer loop and chime playback, then layer scheduling, histories, and analytics gating.
