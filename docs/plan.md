# Plan: Chimely ChatGPT App

This plan describes how to rebuild Chimely as a ChatGPT App while preserving the core timer experience and visual identity. It assumes the ChatGPT Apps SDK is available and that the app will run fully within the ChatGPT client surface.

## Goals
- Recreate the main timer UI (concentric duration/interval rings with a primary action button) in web-native technologies.
- Support flexible timer constraints (fixed duration, interval repetitions, task-linked timeboxes) and configurable chime patterns.
- Provide a minimal, privacy-respecting backend surface for scheduling, persistence, and analytics consent.
- Align with ChatGPT Apps SDK conventions for manifest metadata, actions/tools, and auth.

## Architecture outline
1. **Client (ChatGPT App)**
   - Built with the ChatGPT Apps SDK UI primitives (panels, cards) and custom Canvas/SVG for the concentric rings.
   - State machine mirrors the iOS timer: `idle → primed → running → paused → stopped`, with chime interval tracking.
   - Uses Web Audio API for chime playback with fallbacks for vibration-only or silent cues.
   - Persists active timer state and history to local storage for resilience during conversation context switches.

2. **Backend (optional/replaceable)**
   - REST or edge function endpoints for authenticated users to sync timer presets, histories, and analytics consent.
   - Webhook or scheduled task surface for queued/scheduled timers (future phase).

3. **SDK wiring**
   - Manifest defines the app name, description, allowed domains, and tools for timer creation, control, and status queries.
   - Tool schemas mirror the timer configuration model (duration, interval length, chime preset, notes/task link).

## Delivery milestones
1. **Milestone 1 — Timer shell**
   - Implement ring rendering, primary action button, and countdown logic purely client-side.
   - Deliver start/stop/pause/resume with chime playback.
   - Add accessibility (ARIA labels, focus order, reduced motion toggle) and responsive layout.

2. **Milestone 2 — Presets & history**
   - Add preset CRUD, recent history list, and restoration of the last active timer on load.
   - Wire optional backend sync; keep local storage as the source of truth when offline.

3. **Milestone 3 — Scheduling & automation**
   - Allow scheduled timers and recurring patterns (e.g., daily focus blocks).
   - Expose scheduling as a ChatGPT tool to run in the background with confirmation prompts.

4. **Milestone 4 — Analytics & consent**
   - Implement privacy-first analytics with explicit consent and a local-only mode.
   - Add observability for chime failures, timer drift, and web audio availability.

## Next steps
- Set up the new repository with this folder as the root, initialize package management (e.g., pnpm, npm, or yarn), and install the ChatGPT Apps SDK.
- Translate the SwiftUI reference (`reference/TimerReferenceViews.swift`) into Canvas/SVG components and CSS gradients.
- Define timer state models in TypeScript mirroring `TimerPrimaryButtonState` and interval tracking from the Swift reference.
- Implement tool schemas based on `docs/schemas.md` and wire them into `manifest-template.json` with real URLs.
- Draft UX prototypes that adapt the circular control to the ChatGPT panel layout (mobile and desktop breakpoints).
