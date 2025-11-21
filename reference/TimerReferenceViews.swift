// TimerReferenceViews.swift
// Reference-only SwiftUI components from the current Chimely timer.
// These are non-runnable samples intended to guide the ChatGPT App implementation.

import SwiftUI

/// Button states that drive labeling, gradient colors, and press behavior.
enum TimerPrimaryButtonState {
    case startInactive
    case startActive
    case stop
    case scheduleInactive
    case scheduleActive

    var title: String {
        switch self {
        case .startInactive, .startActive:
            return "Start"
        case .stop:
            return "Stop"
        case .scheduleInactive, .scheduleActive:
            return "Schedule"
        }
    }
}

/// Phase value used for the breathing/pulsing animation on the primary button.
enum TimerButtonPulsePhase {
    case none
    case breathing
}

/// Color tokens and layout numbers used by the concentric timer rings and button.
struct TimerPaletteReference {
    struct Ring {
        static let durationStart = Color(red: 123 / 255, green: 98 / 255, blue: 1.0)
        static let durationEnd = Color(red: 107 / 255, green: 77 / 255, blue: 1.0)
        static let intervalStart = Color(red: 214 / 255, green: 187 / 255, blue: 1.0)
        static let intervalEnd = Color(red: 199 / 255, green: 166 / 255, blue: 1.0)
        static let backgroundOpacity: Double = 0.20
        static let lineWidthRatio: CGFloat = 0.085
        static let minimumLineWidth: CGFloat = 4
        static let gapMultiplier: CGFloat = 0.32
        static let gapRatio: CGFloat = 0.12 * gapMultiplier
    }

    struct Button {
        static let inactive = Color(red: 0.55, green: 0.55, blue: 0.56)
        static let startActive = Color(red: 0.27, green: 0.66, blue: 0.20)
        static let stop = Color(red: 0.87, green: 0.06, blue: 0.00)
        static let scheduleActiveTop = Color(red: 1.0, green: 0.96, blue: 0.78)
        static let scheduleActiveMid = Color(red: 1.0, green: 0.84, blue: 0.20)
        static let scheduleActiveBottom = Color(red: 1.0, green: 0.55, blue: 0.05)
    }
}

/// Concentric progress rings with a pulsing interval dot, styled after Apple Health.
struct TimerProgressIndicatorReference: View {
    var durationProgress: Double
    var intervalProgress: Double
    var totalDuration: TimeInterval
    var chimeInterval: TimeInterval
    var primaryButtonState: TimerPrimaryButtonState
    var shouldBreathePrimaryButton: Bool
    var pulsePhase: TimerButtonPulsePhase
    var onPrimaryAction: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineWidth = max(size * TimerPaletteReference.Ring.lineWidthRatio, TimerPaletteReference.Ring.minimumLineWidth)
            let gap = max(
                size * TimerPaletteReference.Ring.gapRatio,
                TimerPaletteReference.Ring.minimumLineWidth * TimerPaletteReference.Ring.gapMultiplier
            )
            let outerPadding = lineWidth / 2
            let innerPadding = outerPadding + lineWidth + gap
            let innerRingInnerRadius = max(size / 2 - innerPadding - lineWidth / 2, 0)
            let buttonRadius = max(innerRingInnerRadius - gap, 0)
            let buttonDiameter = buttonRadius * 2

            ZStack {
                progressRing(
                    style: .duration,
                    progress: durationProgress.clamped(),
                    lineWidth: lineWidth,
                    nextIntervalFraction: nextIntervalFraction(
                        totalDuration: totalDuration,
                        interval: chimeInterval,
                        progress: durationProgress
                    )
                )
                .padding(outerPadding)

                progressRing(
                    style: .interval,
                    progress: intervalProgress.clamped(),
                    lineWidth: lineWidth,
                    nextIntervalFraction: nil
                )
                .padding(innerPadding)

                primaryButton(diameter: buttonDiameter)
            }
            .frame(width: size, height: size)
        }
    }

    private func nextIntervalFraction(totalDuration: TimeInterval, interval: TimeInterval, progress: Double) -> Double? {
        guard interval > 0, totalDuration > 0 else { return nil }
        let elapsed = progress.clamped() * totalDuration
        let remainder = elapsed.truncatingRemainder(dividingBy: interval)
        return remainder / interval
    }

    @ViewBuilder
    private func progressRing(
        style: RingStyle,
        progress: Double,
        lineWidth: CGFloat,
        nextIntervalFraction: Double?
    ) -> some View {
        let gradient = AngularGradient(
            gradient: Gradient(colors: [
                style.startColor,
                style.midColor,
                style.endColor
            ]),
            center: .center
        )

        ZStack {
            Circle()
                .stroke(style.endColor.opacity(TimerPaletteReference.Ring.backgroundOpacity), lineWidth: lineWidth)

            if let dot = nextIntervalFraction {
                Circle()
                    .fill(style.endColor)
                    .frame(width: lineWidth, height: lineWidth)
                    .offset(y: -(lineWidth / 2))
                    .rotationEffect(.degrees(dot * 360))
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 0.25), value: dot)
            }

            if progress > 0 {
                Circle()
                    .trim(from: 0, to: progress.clamped())
                    .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Circle()
                    .fill(style.interpolatedColor(fraction: progress))
                    .frame(width: lineWidth, height: lineWidth)
                    .offset(y: -(lineWidth / 2))
                    .rotationEffect(.degrees(360 * progress))
            }
        }
    }

    @ViewBuilder
    private func primaryButton(diameter: CGFloat) -> some View {
        let gradient = primaryGradient(for: primaryButtonState)
        let canPulse = shouldBreathePrimaryButton && primaryButtonState != .stop

        Button(action: onPrimaryAction) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: gradient),
                        center: .center,
                        startRadius: diameter * 0.1,
                        endRadius: diameter * 0.5
                    ))
                    .frame(width: diameter, height: diameter)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                Text(primaryButtonState.title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(PrimaryActionButtonStyle(animatePress: true))
        .overlay(
            RippleHalo(diameter: diameter, isActive: canPulse && pulsePhase == .breathing)
        )
    }

    private func primaryGradient(for state: TimerPrimaryButtonState) -> [Color] {
        switch state {
        case .startInactive, .scheduleInactive:
            return [
                TimerPaletteReference.Button.inactive.opacity(0.8),
                TimerPaletteReference.Button.inactive,
                TimerPaletteReference.Button.inactive.opacity(0.9)
            ]
        case .startActive:
            return [
                TimerPaletteReference.Button.startActive.opacity(0.6),
                TimerPaletteReference.Button.startActive,
                TimerPaletteReference.Button.startActive.opacity(0.8)
            ]
        case .stop:
            return [
                TimerPaletteReference.Button.stop.opacity(0.6),
                TimerPaletteReference.Button.stop,
                TimerPaletteReference.Button.stop.opacity(0.75)
            ]
        case .scheduleActive:
            return [
                TimerPaletteReference.Button.scheduleActiveTop,
                TimerPaletteReference.Button.scheduleActiveMid,
                TimerPaletteReference.Button.scheduleActiveBottom
            ]
        }
    }
}

private enum RingStyle {
    case duration
    case interval

    var startColor: Color {
        switch self {
        case .duration: return TimerPaletteReference.Ring.durationStart
        case .interval: return TimerPaletteReference.Ring.intervalStart
        }
    }

    var endColor: Color {
        switch self {
        case .duration: return TimerPaletteReference.Ring.durationEnd
        case .interval: return TimerPaletteReference.Ring.intervalEnd
        }
    }

    var midColor: Color {
        Color(
            red: (startColor.components.red + endColor.components.red) / 2,
            green: (startColor.components.green + endColor.components.green) / 2,
            blue: (startColor.components.blue + endColor.components.blue) / 2
        )
    }

    func interpolatedColor(fraction: Double) -> Color {
        let clamped = fraction.clamped()
        return Color(
            red: startColor.components.red + (endColor.components.red - startColor.components.red) * clamped,
            green: startColor.components.green + (endColor.components.green - startColor.components.green) * clamped,
            blue: startColor.components.blue + (endColor.components.blue - startColor.components.blue) * clamped
        )
    }
}

private struct RippleHalo: View {
    var diameter: CGFloat
    var isActive: Bool

    var body: some View {
        ZStack {
            rippleCircle(multiplier: 1.25, opacity: 0.18)
            rippleCircle(multiplier: 1.55, opacity: 0.12)
        }
        .animation(.easeOut(duration: 0.5), value: isActive)
    }

    private func rippleCircle(multiplier: CGFloat, opacity: Double) -> some View {
        let activeScale: CGFloat = 1.05
        let inactiveScale: CGFloat = 0.85

        return Circle()
            .stroke(Color.white.opacity(opacity), lineWidth: 3)
            .frame(
                width: diameter * (isActive ? multiplier * activeScale : multiplier * inactiveScale),
                height: diameter * (isActive ? multiplier * activeScale : multiplier * inactiveScale)
            )
            .opacity(isActive ? 0 : opacity)
            .blur(radius: 1.2)
            .animation(.easeOut(duration: 0.6), value: isActive)
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    var animatePress: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(animatePress && configuration.isPressed ? 0.92 : 1)
            .animation(
                animatePress ? .spring(response: 0.18, dampingFraction: 0.7, blendDuration: 0.1) : nil,
                value: configuration.isPressed
            )
    }
}

private extension Double {
    func clamped() -> Double { min(max(self, 0), 1) }
}

private extension Color {
    /// Extract RGB components for interpolation. Suitable for reference-only use.
    var components: (red: Double, green: Double, blue: Double) {
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
        #else
        return (0, 0, 0)
        #endif
    }
}

#Preview("Reference Timer") {
    TimerProgressIndicatorReference(
        durationProgress: 0.65,
        intervalProgress: 0.35,
        totalDuration: 1800,
        chimeInterval: 300,
        primaryButtonState: .startActive,
        shouldBreathePrimaryButton: true,
        pulsePhase: .breathing,
        onPrimaryAction: {}
    )
    .padding(24)
    .background(Color.black)
}
