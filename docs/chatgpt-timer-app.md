# Chimely ChatGPT App Timer Plan

This document records the requirements, architecture, implementation plan, and prompt scaffolding for the pico.ai Chimely ChatGPT App. It captures the guidance from the prior planning conversation so future agents can continue the build.

## Requirements
- **Timer experience in ChatGPT:** Provide a horizontal timer widget embedded in-chat that mirrors Chimely's calm aesthetic (dual rings/gradients) and updates continuously while active.
- **Background continuity:** Timer state and chime scheduling must persist when the widget is hidden; interval chimes and penultimate cues still fire on time (Web Audio + vibration fallback).
- **Flexible timer definition:** Accept natural-language intents describing rich timers (collections of chime points, intervals, labels, sounds, total duration) beyond the legacy model; surface these as structured "TimerPlan" objects.
- **Accessibility:** Keyboard operability, ARIA labels, high contrast, reduced motion toggle, and large tap targets.
- **Apps SDK & MCP:** Implement as a ChatGPT App using the Apps SDK with an MCP server for tool execution; manifest and tools must register MCP endpoints.
- **Design guidelines:** Follow official Apps SDK design guidelines for layout, spacing, and component usage; align with pico.ai branding.
- **Deployment:** Target Node.js/TypeScript web stack (e.g., Vercel) for hosting MCP server endpoints and static assets; avoid Swift/SwiftUI (Swift references are only inspirational).

## Proposed Architecture
### Client (ChatGPT App surface)
- TypeScript + Apps SDK UI components for chat-embedded panels; custom SVG/Canvas for a horizontal timer widget with dual progress tracks.
- State machines for timer lifecycle (`idle → primed → running → paused → stopped`) and chime scheduler mirroring reference behavior.
- Web Audio API for scheduled chimes; `requestAnimationFrame` for progress; background timers + persisted state (local storage) to survive context switches.
- Accessibility: ARIA roles/labels, focus order, reduced-motion mode, high-contrast gradients from design tokens.

### MCP Server (Node.js)
- Handles deterministic timer computations, storage, and structured responses to natural-language requests. Exposes tools over MCP per Apps SDK requirements.
- Responsibilities:
  - Parse natural-language timer intents (with pre-prompts) into structured TimerPlan objects (duration, chime points, intervals, labels, sound themes).
  - Persist active timers and history (in-memory or edge KV initially; pluggable DB later).
  - Provide control endpoints (`start`, `pause`, `resume`, `stop`, `status`) and schedule handling.
  - Emit timer tick/chime events to the client via Apps SDK data channels or polling.

### Data Model
- **TimerPlan:** `id`, `totalDurationMs`, `segments[]` (each with `startMs`, `endMs`, `label`, `soundId`, `chimeAt[]`), `loop`/`repeat`, `theme`.
- **RuntimeState:** `status`, `elapsedMs`, `nextChimeMs`, `intervalProgress`, `durationProgress`, `muted`, `vibrateOnly`.
- **HistoryEntry:** `planId`, `actualDurationMs`, `completed`, `stoppedReason`, `timestamps`.

### Storage
- Client: Local storage for active timer snapshot and preferences.
- Server: Edge KV (e.g., Vercel KV) or in-memory store for MVP; abstracted repository layer for portability.

### Deployment & DevOps
- Hosting: Vercel project under pico.ai; deploy MCP server as Vercel Functions/Edge Functions; serve static client assets from Vercel.
- Manifest: Update `manifest-template.json` with production URLs and MCP tool references; include MCP server info and allowed domains.
- Testing: Unit tests for timer math and chime scheduling; integration tests for Apps SDK tool calls; linting via ESLint/TypeScript.

## Implementation Plan
1. **Repo setup**: Initialize Node.js/TypeScript workspace with Apps SDK dependencies. Add Vercel config and package scripts for lint/test/build.
2. **Manifest & MCP wiring**: Replace `api.url` in `manifest-template.json` with deployed MCP endpoint; register MCP server per Apps SDK docs. Define MCP tools (`create_timer`, `control_timer`, `get_timer_status`, `list_history`, `schedule_timer`) aligned to the TimerPlan model.
3. **Pre-prompts for NL → TimerPlan**: Craft system prompts instructing the model to output the TimerPlan schema (segments, chime points, labels, sounds, total duration) with constraints (durations in ms, sound IDs from allowed set) plus examples.
4. **MCP server implementation**: Build a TypeScript MCP server that validates model output against the TimerPlan schema, maintains active timer state, computes chime schedules, and exposes status snapshots. Add tests for timer math (progress, chime offsets, penultimate cue).
5. **Client timer widget**: Implement a horizontal panel component with dual progress tracks and chime markers. Use `requestAnimationFrame` for progress and Web Audio API for chime scheduling with vibration fallback. Ensure off-screen continuity and reconnection to the MCP server.
6. **Controls & interactions**: Provide a primary action button reflecting states (start/stop/pause/resume), gradients from design tokens, mute/vibrate toggles, progress text, and next-chime indicator.
7. **Accessibility & design compliance**: Apply ARIA roles, focus management, reduced-motion handling, and high-contrast styles per Apps SDK design guidelines.
8. **Persistence & history**: Store last active timer and recent history locally; expose server history via MCP `list_history`. Auto-log sessions that complete naturally.
9. **Testing & observability**: Add lint/test to CI; instrument timer drift/chime failures with minimal telemetry and privacy safeguards.
10. **Deployment**: Deploy MCP server and client to Vercel; update manifest URLs; validate end-to-end in ChatGPT Apps sandbox ensuring chimes fire while widget is hidden.

## Sample Pre-Prompts (NL → TimerPlan)
- **System prompt snippet:**
  - "You are the Timer Planner for pico.ai's Chimely ChatGPT App. Convert user requests into a `TimerPlan` JSON with `totalDurationMs`, `segments[]` (each has `startMs`, `endMs`, `label`, `soundId`, `chimeAt[]`), and optional `repeat`. Include a penultimate chime if total duration allows. Do not invent sounds outside the allowed list: `bell_soft`, `bell_bright`, `woodblock`, `breathe`, `silence`."
- **Few-shot example:**
  - User: "20-minute focus with soft chimes every 5 minutes and a bright final bell." → TimerPlan with four 5-minute segments, `chimeAt` at segment ends, final `soundId: bell_bright`.
- **Validation prompt:**
  - "If `totalDurationMs` < max(`chimeAt`), adjust or fail with explanation. Ensure durations are integers (ms) and labels are concise."
