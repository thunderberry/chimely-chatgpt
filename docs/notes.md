# Context notes

These notes capture the behaviors and constraints from the existing iOS app that should guide the ChatGPT App implementation.

## Timer behaviors to preserve
- Dual-ring progress: outer ring tracks total duration; inner ring tracks interval progress with a pulsing dot for the upcoming chime.
- Primary button states: `startInactive` (disabled when config incomplete), `startActive`, `stop`, `scheduleActive`/`Inactive` for queued timers, plus press animations.
- Chime cadence: configurable interval with optional penultimate cue and vibrate-only mode; support for duration-only timers.
- History finalization: timers that complete naturally should auto-log without marking as manually stopped.
- Accessibility: large tap targets, high-contrast gradients, reduced-motion alternative when animation is disabled.

## Design tokens
- Dark canvas background, with concentric gradients:
  - **Duration ring:** start RGB `(123, 98, 255)` → end `(107, 77, 255)`.
  - **Interval ring:** start RGB `(214, 187, 255)` → end `(199, 166, 255)`.
  - Ring line width ≈ 8.5% of diameter (min 4pt); gap ratio ≈ `0.12 * 0.32` to retain spacing.
- Primary button gradients:
  - Start active: rich green with lighter top highlight.
  - Stop: bright red with darker base.
  - Schedule active: warm gold gradient (`#fff4c7 → #ffd733 → #ff8c0d`).

## State model (simplified)
- `TimerPrimaryButtonState`: governs label, color, and enabled state.
- `TimerButtonPulsePhase`: drives breathing animation when primed.
- Progress inputs: `durationProgress` and `intervalProgress` normalized to `0...1`, with optional `nextIntervalFraction` to position the pulsing dot.

## Chime and interval logic
- Next interval position is calculated from `(elapsed mod interval) / interval`, clamped to 0...1.
- When duration progress reaches 100%, animations stop and the button switches to reset/start.
- Penultimate chime is emitted one interval before completion when enabled.

## Web implementation notes
- Use Canvas or SVG for rings; CSS `conic-gradient` can approximate the SwiftUI `AngularGradient`.
- Prefer `requestAnimationFrame` for smooth progress updates; throttle to 60fps and respect `prefers-reduced-motion`.
- Web Audio API can schedule short sounds; offer vibration fallback via `navigator.vibrate` when supported.
