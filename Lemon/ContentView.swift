import SwiftUI
import UIKit

struct LemonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.minX + w * 0.85, y: rect.minY),
            control2: CGPoint(x: rect.maxX, y: rect.minY + h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.maxY - h * 0.2),
            control2: CGPoint(x: rect.minX + w * 0.85, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control1: CGPoint(x: rect.minX + w * 0.15, y: rect.maxY),
            control2: CGPoint(x: rect.minX, y: rect.maxY - h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.minY + h * 0.2),
            control2: CGPoint(x: rect.minX + w * 0.15, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// A full, belled princess skirt: a narrow waistband flaring out along
/// curved (not straight) sides into a scalloped, ruffled hem — rather than
/// a flat-edged triangle.
struct PrincessSkirtShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { fraction(rect, x, y) }

        // Waistband.
        path.move(to: p(0.40, 0.0))
        path.addLine(to: p(0.60, 0.0))

        // Right side, belling outward.
        path.addCurve(to: p(0.94, 0.78), control1: p(0.66, 0.18), control2: p(0.92, 0.42))

        // Scalloped hem, right to left.
        path.addCurve(to: p(0.76, 0.86), control1: p(0.90, 0.94), control2: p(0.82, 0.94))
        path.addCurve(to: p(0.58, 0.86), control1: p(0.70, 0.78), control2: p(0.64, 0.78))
        path.addCurve(to: p(0.40, 0.86), control1: p(0.52, 0.94), control2: p(0.46, 0.94))
        path.addCurve(to: p(0.22, 0.86), control1: p(0.34, 0.78), control2: p(0.28, 0.78))
        path.addCurve(to: p(0.06, 0.78), control1: p(0.16, 0.94), control2: p(0.10, 0.94))

        // Left side, back up to the waistband.
        path.addCurve(to: p(0.40, 0.0), control1: p(0.08, 0.42), control2: p(0.34, 0.18))

        path.closeSubpath()
        return path
    }
}

/// A ring with a hole punched out of the lower-middle (rather than dead
/// center) so the face has clear room to sit above it. Fill with
/// `FillStyle(eoFill: true)` so the hole actually cuts through.
struct DonutShape: Shape {
    /// Shrinks the outer edge in from `rect` while the hole stays anchored
    /// to the original `rect` — lets a frosting layer sit inset from the
    /// dough's outer rim without its hole drifting out of alignment.
    var outerInset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect.insetBy(dx: outerInset, dy: outerInset))

        let holeSize = min(rect.width, rect.height) * 0.28
        let holeRect = CGRect(
            x: rect.midX - holeSize / 2,
            y: rect.midY - holeSize / 2 + rect.height * 0.1,
            width: holeSize,
            height: holeSize
        )
        path.addEllipse(in: holeRect)

        return path
    }
}

/// A simple rounded heart — two lobes at the top meeting at a point at the
/// bottom — used for Cool Lemon's sunglasses lenses.
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { fraction(rect, x, y) }

        path.move(to: p(0.5, 0.92))
        path.addCurve(to: p(0.02, 0.38), control1: p(0.35, 0.75), control2: p(0.02, 0.58))
        path.addCurve(to: p(0.24, 0.02), control1: p(0.02, 0.16), control2: p(0.14, 0.02))
        path.addCurve(to: p(0.5, 0.24), control1: p(0.36, 0.02), control2: p(0.46, 0.1))
        path.addCurve(to: p(0.76, 0.02), control1: p(0.54, 0.1), control2: p(0.64, 0.02))
        path.addCurve(to: p(0.98, 0.38), control1: p(0.86, 0.02), control2: p(0.98, 0.16))
        path.addCurve(to: p(0.5, 0.92), control1: p(0.98, 0.58), control2: p(0.65, 0.75))

        path.closeSubpath()
        return path
    }
}

/// The two curved seam lines wrapping a tennis ball, simplified to a pair
/// of open arcs with 180°-rotational symmetry about the center — one
/// running from the left edge up into the upper-right, the other from the
/// right edge down into the lower-left — so together they read as one
/// continuous "S" band rather than a symmetric eye/lens shape. Meant to be
/// stroked, not filled.
struct TennisSeamShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { fraction(rect, x, y) }

        path.move(to: p(0.2, 0.0))
        path.addQuadCurve(to: p(1.0, 0.5), control: p(0.38, 0.22))

        path.move(to: p(0.8, 1.0))
        path.addQuadCurve(to: p(0.0, 0.5), control: p(0.62, 0.78))

        return path
    }
}

/// A regular, point-up pentagon — the central patch of a soccer ball.
struct PentagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.16

        for i in 0..<5 {
            let angle = Angle(degrees: -90 + Double(i) * 72).radians
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

/// Thin seam lines connecting the nearest corners of adjoining panels —
/// two from the central pentagon out to each surrounding panel, and one
/// between each pair of neighboring panels — so the pattern reads as one
/// stitched ball rather than separate floating shapes. Computed once for
/// the panel at -54° and rotated by 72° steps for the other four, matching
/// the layout's 5-fold symmetry.
struct SoccerLinksShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseSegments: [(CGPoint, CGPoint)] = [
            (CGPoint(x: 0, y: -48), CGPoint(x: 10.19, y: -62.02)),
            (CGPoint(x: 45.65, y: -14.83), CGPoint(x: 55.84, y: -28.86)),
            (CGPoint(x: 55.84, y: -28.86), CGPoint(x: 62.14, y: -9.48))
        ]

        for i in 0..<5 {
            let rotation = Angle(degrees: Double(i) * 72).radians
            for (a, b) in baseSegments {
                let ra = rotated(a, by: rotation)
                let rb = rotated(b, by: rotation)
                path.move(to: CGPoint(x: center.x + ra.x, y: center.y + ra.y))
                path.addLine(to: CGPoint(x: center.x + rb.x, y: center.y + rb.y))
            }
        }
        return path
    }

    private func rotated(_ point: CGPoint, by radians: Double) -> CGPoint {
        let cosA = cos(radians)
        let sinA = sin(radians)
        return CGPoint(x: point.x * cosA - point.y * sinA, y: point.x * sinA + point.y * cosA)
    }
}

enum DanceDirection: CaseIterable, Equatable {
    case up, down, left, right

    var symbolName: String {
        switch self {
        case .up: return "arrow.up.circle.fill"
        case .down: return "arrow.down.circle.fill"
        case .left: return "arrow.left.circle.fill"
        case .right: return "arrow.right.circle.fill"
        }
    }

    var frequency: Double {
        switch self {
        case .up: return 523.25    // C5 - "Do"
        case .down: return 261.63  // C4 - "Do"
        case .left: return 293.66  // D4 - "Da"
        case .right: return 392.00 // G4 - "Da"
        }
    }

    var offset: CGSize {
        switch self {
        case .up: return CGSize(width: 0, height: -34)
        case .down: return CGSize(width: 0, height: 22)
        case .left: return CGSize(width: -32, height: 0)
        case .right: return CGSize(width: 32, height: 0)
        }
    }

    var rotation: Double {
        switch self {
        case .up: return 0
        case .down: return 0
        case .left: return -14
        case .right: return 14
        }
    }

    var squash: CGSize {
        switch self {
        case .up: return CGSize(width: 0.95, height: 1.08)
        case .down: return CGSize(width: 1.08, height: 0.9)
        case .left, .right: return CGSize(width: 1, height: 1)
        }
    }

    /// Shoulder-pivot rotation for the (left, right) arms, in degrees. 0 = hanging straight down.
    var armAngles: (left: Double, right: Double) {
        switch self {
        case .up: return (-155, 155)
        case .down: return (-35, 35)
        case .left: return (-85, 55)
        case .right: return (-55, 85)
        }
    }

    /// Hip-pivot offset for the (left, right) legs.
    var legOffsets: (left: CGSize, right: CGSize) {
        switch self {
        case .up: return (CGSize(width: 0, height: -12), CGSize(width: 0, height: -12))
        case .down: return (CGSize(width: -6, height: 6), CGSize(width: 6, height: 6))
        case .left: return (CGSize(width: -18, height: -4), CGSize(width: 4, height: 0))
        case .right: return (CGSize(width: -4, height: 0), CGSize(width: 18, height: -4))
        }
    }
}

enum InputAction: Equatable {
    case direction(DanceDirection)
    case twirl
}

/// Fraction-of-rect helper so the pitcher parts stay aligned to each other
/// whatever frame they are drawn in.
private func fraction(_ rect: CGRect, _ x: CGFloat, _ y: CGFloat) -> CGPoint {
    CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
}

/// The jug body of the lemonade pitcher: wide shoulders that keep the arms
/// attached, a taper down to a narrow base, and a short lip on the right that
/// the rim's spout overhangs. Drawn in the same 260x220 frame as `LemonShape`.
struct PitcherShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { fraction(rect, x, y) }

        // Mouth.
        path.move(to: p(0.13, 0.09))
        path.addLine(to: p(0.79, 0.09))
        // Short lip, folding back into the right wall.
        path.addQuadCurve(to: p(0.91, 0.19), control: p(0.87, 0.11))
        path.addQuadCurve(to: p(0.91, 0.30), control: p(0.93, 0.25))
        // Right wall: shoulder out, then taper in to the base.
        path.addCurve(to: p(0.74, 0.93), control1: p(0.98, 0.46), control2: p(0.88, 0.80))
        // Base.
        path.addCurve(to: p(0.26, 0.93), control1: p(0.62, 1.01), control2: p(0.38, 1.01))
        // Left wall back up to the mouth.
        path.addCurve(to: p(0.09, 0.27), control1: p(0.14, 0.80), control2: p(0.02, 0.46))
        path.addQuadCurve(to: p(0.13, 0.09), control: p(0.08, 0.15))
        path.closeSubpath()

        return path
    }
}

/// The rim of the pitcher, drawn as an ellipse pulled out into a beak on the
/// right so the mouth and the pouring spout read as one continuous piece.
struct PitcherRimShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { fraction(rect, x, y) }

        path.move(to: p(0.0, 0.5))
        path.addCurve(to: p(0.70, 0.04), control1: p(0.04, 0.02), control2: p(0.34, 0.0))
        path.addQuadCurve(to: p(1.0, 0.34), control: p(0.89, 0.06))   // out into the beak
        path.addQuadCurve(to: p(0.72, 0.96), control: p(0.90, 0.80))  // and back under it
        path.addCurve(to: p(0.0, 0.5), control1: p(0.36, 1.0), control2: p(0.04, 0.98))
        path.closeSubpath()

        return path
    }
}

/// Centre line of the pitcher's handle. Open on purpose: it is stroked, not
/// filled, and drawn behind the body so the joints are hidden by the wall.
struct PitcherHandleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { fraction(rect, x, y) }

        path.move(to: p(0.15, 0.32))
        path.addCurve(to: p(0.22, 0.78), control1: p(-0.18, 0.38), control2: p(-0.18, 0.74))

        return path
    }
}

/// Short original riffs for the special moves, as note frequencies in Hz.
/// Played one note at a time through `ToneSynth`'s sine wave. None of these
/// are quotes of real songs — they're arcade-style stingers built for punch,
/// not for being hummable.
enum Tune {
    /// Rising "ta-daa!" fanfare — LEMON POWER.
    static let lemonPower: [Double] = [523.25, 523.25, 523.25, 659.25, 783.99, 1046.50, 783.99, 1046.50, 1318.51]
    /// Pentatonic coin-bounce arpeggio, up and back down — Clementine.
    static let clementine: [Double] = [523.25, 659.25, 783.99, 1046.50, 783.99, 659.25, 523.25]
    /// Chromatic downward sting — Lime.
    static let lime: [Double] = [880.00, 783.99, 739.99, 698.46, 587.33, 440.00]
    /// Ascending "pour" run with a wide leap at the top — Lemonade Pitcher.
    static let lemonadePitcher: [Double] = [392.00, 440.00, 493.88, 587.33, 698.46, 880.00, 1046.50]
    /// Gritty minor-third power riff — STRONG LEMON flex.
    static let flex: [Double] = [261.63, 311.13, 392.00, 523.25, 392.00, 523.25]
    /// Sparkle run for the plain twirl button.
    static let twirl: [Double] = [523.25, 659.25, 783.99, 1046.50, 783.99, 659.25, 880.00, 1046.50]
    /// Slow, unhurried descent — a distinguished riff for the beard.
    static let singleSingleDoubleDouble: [Double] = [392.00, 329.63, 261.63, 196.00]
    /// Bouncy two-note "woof" — Ruby.
    static let ruby: [Double] = [523.25, 523.25, 392.00, 523.25, 659.25]
    /// Sleek descending slink with a flick at the end — Marble.
    static let marble: [Double] = [659.25, 587.33, 523.25, 440.00, 523.25]
    /// Alternating low two-note dread — Lemon Shark.
    static let lemonShark: [Double] = [164.81, 174.61, 164.81, 174.61, 164.81, 174.61]
    /// Fast ascending sprint run — Runner.
    static let runner: [Double] = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 523.25]
    /// Light, high, bouncy chime — Baby Lemon.
    static let babyLemon: [Double] = [1046.50, 659.25, 783.99, 1046.50]
    /// Rising arpeggio with a glittery flourish — Princess.
    static let princess: [Double] = [523.25, 659.25, 783.99, 1046.50, 783.99, 1046.50]
    /// Bouncy, sugary little jingle — Donut.
    static let donut: [Double] = [587.33, 587.33, 880.00, 783.99, 659.25, 880.00]
    /// A crisp little "crunch and polish" riff — Apple.
    static let apple: [Double] = [659.25, 783.99, 987.77, 880.00, 987.77, 1174.66]
    /// A tarter, brighter variant of Apple's riff — Green Apple.
    static let greenApple: [Double] = [698.46, 830.61, 1046.50, 932.33, 1046.50, 1244.51]
    /// A laid-back, swaggering little slide — Cool Lemon.
    static let coolLemon: [Double] = [392.00, 493.88, 440.00, 587.33, 523.25]
    /// A springy, bouncing-ball riff — Tennis Ball.
    static let tennisBall: [Double] = [523.25, 392.00, 523.25, 392.00, 659.25, 493.88]
    /// A light, cheerful little skip — Daisy.
    static let daisy: [Double] = [659.25, 739.99, 830.61, 739.99, 987.77, 880.00]
    /// A punchy, kicking-off riff — Soccer Ball.
    static let soccerBall: [Double] = [440.00, 440.00, 587.33, 523.25, 698.46, 587.33]
}

enum Fruit: Equatable {
    case lemon, clementine, lime, lemonadePitcher
    case singleSingleDoubleDouble, ruby, marble, lemonShark, runner, princess, donut, apple, greenApple, coolLemon, tennisBall, daisy, soccerBall

    var bodyColors: (light: Color, dark: Color, stroke: Color) {
        switch self {
        case .lemon, .singleSingleDoubleDouble, .runner, .princess, .coolLemon:
            return (Color(red: 1.0, green: 0.93, blue: 0.35), Color(red: 0.98, green: 0.78, blue: 0.1), Color(red: 0.75, green: 0.58, blue: 0.05))
        case .clementine:
            return (Color(red: 1.0, green: 0.68, blue: 0.32), Color(red: 0.95, green: 0.48, blue: 0.12), Color(red: 0.75, green: 0.35, blue: 0.05))
        case .lime:
            return (Color(red: 0.78, green: 0.92, blue: 0.42), Color(red: 0.55, green: 0.78, blue: 0.22), Color(red: 0.32, green: 0.5, blue: 0.1))
        case .lemonadePitcher:
            // Cool, pale tones for the glass sheen, handle, rim and limbs —
            // the warm lemonade color comes from `pitcherGlassBody`'s liquid
            // fill instead, so the vessel itself reads as clear glass.
            return (Color(red: 0.93, green: 0.97, blue: 0.99), Color(red: 0.80, green: 0.90, blue: 0.94), Color(red: 0.53, green: 0.64, blue: 0.68))
        case .ruby:
            // Gray-and-white, matching Ruby's shaggy coat.
            return (Color(red: 0.97, green: 0.96, blue: 0.94), Color(red: 0.55, green: 0.55, blue: 0.58), Color(red: 0.35, green: 0.35, blue: 0.38))
        case .marble:
            // Black-and-white tuxedo coloring, matching Marble's markings.
            return (Color(red: 0.98, green: 0.98, blue: 0.98), Color(red: 0.15, green: 0.15, blue: 0.17), Color(red: 0.1, green: 0.1, blue: 0.12))
        case .lemonShark:
            // Tan-gray, like the real fish this is punning on.
            return (Color(red: 0.88, green: 0.82, blue: 0.5), Color(red: 0.72, green: 0.65, blue: 0.32), Color(red: 0.5, green: 0.44, blue: 0.2))
        case .donut:
            // Strawberry frosting covers the whole ring, so light/dark are
            // frosting tones; stroke stays a baked-dough brown for the rim
            // outline and the arms/legs, so the limbs still read as dough.
            return (Color(red: 1.0, green: 0.68, blue: 0.8), Color(red: 0.93, green: 0.4, blue: 0.6), Color(red: 0.55, green: 0.38, blue: 0.22))
        case .apple:
            return (Color(red: 0.95, green: 0.22, blue: 0.24), Color(red: 0.72, green: 0.06, blue: 0.12), Color(red: 0.42, green: 0.06, blue: 0.08))
        case .greenApple:
            return (Color(red: 0.75, green: 0.88, blue: 0.35), Color(red: 0.52, green: 0.72, blue: 0.16), Color(red: 0.3, green: 0.44, blue: 0.09))
        case .tennisBall:
            // "Optic yellow" — more yellow than green, unlike a plain lime.
            // The pale seam is drawn separately in `tennisSeams`.
            return (Color(red: 0.88, green: 0.9, blue: 0.3), Color(red: 0.75, green: 0.77, blue: 0.16), Color(red: 0.48, green: 0.5, blue: 0.1))
        case .daisy:
            // Rich golden center; the white petals are drawn separately in
            // `daisyPetals`.
            return (Color(red: 1.0, green: 0.82, blue: 0.15), Color(red: 0.92, green: 0.65, blue: 0.05), Color(red: 0.62, green: 0.42, blue: 0.04))
        case .soccerBall:
            // Off-white panels; the black pentagon pattern is drawn
            // separately in `soccerPattern`.
            return (Color(red: 0.98, green: 0.98, blue: 0.98), Color(red: 0.85, green: 0.85, blue: 0.87), Color(red: 0.2, green: 0.2, blue: 0.22))
        }
    }

    var usesFlower: Bool { self == .clementine }
    var isPitcher: Bool { self == .lemonadePitcher }
    var isDog: Bool { self == .ruby }
    var isCat: Bool { self == .marble }
    var hasSharkFin: Bool { self == .lemonShark }
    var hasBeard: Bool { self == .singleSingleDoubleDouble }
    var hasRunningShoes: Bool { self == .runner }
    var hasPrincessDress: Bool { self == .princess }
    var isDonut: Bool { self == .donut }
    /// Gets a brown stem instead of the usual round nub, plus a glossy
    /// highlight on the body.
    var isApple: Bool { self == .apple || self == .greenApple }
    var hasSunglasses: Bool { self == .coolLemon }
    var isTennisBall: Bool { self == .tennisBall }
    var isDaisy: Bool { self == .daisy }
    var isSoccerBall: Bool { self == .soccerBall }

    var name: String {
        switch self {
        case .lemon: return "Lemon"
        case .clementine: return "Clementine"
        case .lime: return "Lime"
        case .lemonadePitcher: return "Lemonade Pitcher"
        case .singleSingleDoubleDouble: return "Single Single Double Double"
        case .ruby: return "Ruby"
        case .marble: return "Marble"
        case .lemonShark: return "Lemon Shark"
        case .runner: return "Runner"
        case .princess: return "Princess"
        case .donut: return "Donut"
        case .apple: return "Apple"
        case .greenApple: return "Green Apple"
        case .coolLemon: return "Cool Lemon"
        case .tennisBall: return "Tennis Ball"
        case .daisy: return "Daisy"
        case .soccerBall: return "Soccer Ball"
        }
    }

    /// Each form gets its own melody so the combos are told apart by ear.
    var tune: [Double] {
        switch self {
        case .lemon: return Tune.lemonPower
        case .clementine: return Tune.clementine
        case .lime: return Tune.lime
        case .lemonadePitcher: return Tune.lemonadePitcher
        case .singleSingleDoubleDouble: return Tune.singleSingleDoubleDouble
        case .ruby: return Tune.ruby
        case .marble: return Tune.marble
        case .lemonShark: return Tune.lemonShark
        case .runner: return Tune.runner
        case .princess: return Tune.princess
        case .donut: return Tune.donut
        case .apple: return Tune.apple
        case .greenApple: return Tune.greenApple
        case .coolLemon: return Tune.coolLemon
        case .tennisBall: return Tune.tennisBall
        case .daisy: return Tune.daisy
        case .soccerBall: return Tune.soccerBall
        }
    }

    var bannerText: String {
        switch self {
        case .lemon: return "🍋 LEMON POWER! 🍋"
        case .clementine: return "🍊 CLEMENTINE TIME! 🍊"
        case .lime: return "🍋‍🟩 LIME TIME! 🍋‍🟩"
        case .lemonadePitcher: return "🥤 LEMONADE TIME! 🥤"
        case .singleSingleDoubleDouble: return "🧔 SINGLE SINGLE DOUBLE DOUBLE! 🧔"
        case .ruby: return "🐶 IT'S RUBY! 🐶"
        case .marble: return "🐱 IT'S MARBLE! 🐱"
        case .lemonShark: return "🦈 LEMON SHARK! 🦈"
        case .runner: return "🏃 GO GO GO! 🏃"
        case .princess: return "👑 ROYAL LEMON! 👑"
        case .donut: return "🍩 DONUT TIME! 🍩"
        case .apple: return "🍎 SHINY RED APPLE! 🍎"
        case .greenApple: return "🍏 SHINY GREEN APPLE! 🍏"
        case .coolLemon: return "😎 COOL LEMON! 😎"
        case .tennisBall: return "🎾 TENNIS BALL! 🎾"
        case .daisy: return "🌼 DAISY! 🌼"
        case .soccerBall: return "⚽ SOCCER BALL! ⚽"
        }
    }
}

enum ComboKind {
    case lemonPower
    case transform(Fruit)
    case flex
    case addBabyLemon
}

enum ComboDiscovery {
    private static func key(_ id: String) -> String { "comboDiscovered_\(id)" }
    private static func hintKey(_ id: String) -> String { "comboHintCount_\(id)" }

    static func isDiscovered(_ id: String) -> Bool {
        UserDefaults.standard.bool(forKey: key(id))
    }

    static func markDiscovered(_ id: String) {
        UserDefaults.standard.set(true, forKey: key(id))
    }

    /// How many steps of the combo's sequence the player has revealed via
    /// the "Hint" button, from the start of the sequence.
    static func hintCount(_ id: String) -> Int {
        UserDefaults.standard.integer(forKey: hintKey(id))
    }

    /// Reveals one more step, up to `total` (the full sequence length).
    static func revealNextHint(_ id: String, total: Int) {
        let next = min(hintCount(id) + 1, total)
        UserDefaults.standard.set(next, forKey: hintKey(id))
    }

    static func reset(_ id: String) {
        UserDefaults.standard.removeObject(forKey: key(id))
        UserDefaults.standard.removeObject(forKey: hintKey(id))
    }
}

struct ContentView: View {
    @State private var isAwake = false
    @State private var moveOffset: CGSize = .zero
    @State private var moveRotation: Double = 0
    @State private var moveScale: CGSize = CGSize(width: 1, height: 1)
    @State private var wakePulse: CGFloat = 1

    @State private var leftArmAngle: Double = -20
    @State private var rightArmAngle: Double = 20
    @State private var leftForearmAngle: Double = 0
    @State private var rightForearmAngle: Double = 0
    @State private var showMuscles = false
    @State private var leftLegOffset: CGSize = .zero
    @State private var rightLegOffset: CGSize = .zero

    @State private var twirlRotation: Double = 0
    @State private var isBusy = false
    @State private var lightsLit = false

    @State private var inputHistory: [InputAction] = []
    @State private var bannerText = ""
    @State private var showBanner = false
    @State private var currentForm: Fruit = .lemon
    @State private var showBabyLemon = false
    @State private var showHelp = false

    /// Normal app launch always starts asleep as a plain lemon — the defaults
    /// here match that. Previews (see PreviewGallery.swift) pass other values
    /// to jump straight to a specific form without walking through combos.
    init(previewForm: Fruit = .lemon, previewAwake: Bool = false, previewBabyLemon: Bool = false) {
        _currentForm = State(initialValue: previewForm)
        _isAwake = State(initialValue: previewAwake)
        _showBabyLemon = State(initialValue: previewBabyLemon)
    }

    private let synth = ToneSynth()

    /// Reference canvas the whole scene is designed at (an iPhone-sized screen).
    /// On a bigger screen — chiefly iPad — this gets uniformly scaled up via
    /// `GeometryReader` instead of leaving the fixed-size character and controls
    /// looking tiny and lost in the middle of a much larger display.
    private let referenceWidth: CGFloat = 402
    private let referenceHeight: CGFloat = 874

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.92)
                .ignoresSafeArea()

            GeometryReader { geo in
                // Only scale up on iPad; on iPhone this is a no-op that renders
                // exactly as it did before scaling existed, since the canvas
                // size equals geo.size and scale is 1 — GeometryReader's own
                // safe-area-respecting frame keeps the layout exactly where it
                // was, arrows and help button included.
                let isPad = UIDevice.current.userInterfaceIdiom == .pad
                let scale = isPad ? min(geo.size.width / referenceWidth, geo.size.height / referenceHeight) : 1
                let canvasWidth = isPad ? referenceWidth : geo.size.width
                let canvasHeight = isPad ? referenceHeight : geo.size.height

                sceneContent
                    .frame(width: canvasWidth, height: canvasHeight)
                    .scaleEffect(scale)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
    }

    private var sceneContent: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()

                ZStack {
                    partyLights

                    lemonCharacter
                        .scaleEffect(wakePulse)
                        .onTapGesture {
                            guard !isAwake else { return }
                            wake()
                        }

                    if showBanner {
                        Text(bannerText)
                            .font(.title2.weight(.heavy))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.6),
                                        Color(red: 0.6, green: 0.4, blue: 1.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(y: -210)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(isAwake ? currentForm.name : "Tap to wake up")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.55, green: 0.42, blue: 0.05))

                Spacer()

                if isAwake {
                    VStack(spacing: 24) {
                        dpad
                        twirlButton
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    .padding(.bottom, 40)
                }
            }

            VStack {
                HStack {
                    Spacer()
                    helpButton
                }
                Spacer()
            }
            .padding()
        }
    }

    private var helpButton: some View {
        Button {
            showHelp = true
        } label: {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color(red: 0.75, green: 0.58, blue: 0.05))
        }
        .buttonStyle(.plain)
    }

    /// Builds a complete character — body, face, form-specific decorations,
    /// arms and legs — for any `Fruit`. Driven entirely by the `form`
    /// parameter (never `currentForm` directly) plus the shared arm/leg/face
    /// animation state, so it produces an identical result whether it's
    /// rendering the main character or (scaled down) `babyLemonCompanion`.
    /// This is what makes the baby an exact, automatically up-to-date
    /// replica of whatever form the main lemon currently is, including any
    /// forms added later.
    private func characterBody(form: Fruit) -> some View {
        let colors = form.bodyColors
        let bodyShape: AnyShape = form.isPitcher ? AnyShape(PitcherShape()) : AnyShape(LemonShape())

        return ZStack {
            // Behind the body so the handle's joints are hidden by the wall.
            if form.isPitcher {
                pitcherHandle(colors: colors)
            }
            // Behind the body so only each petal's outer portion peeks out.
            if form.isDaisy {
                daisyPetals
            }

            if form.isPitcher {
                pitcherGlassBody(colors: colors, bodyShape: bodyShape)
            } else if form.isDonut {
                donutBody(colors: colors)
            } else {
                // Daisy's "body" is just the small center disc — the
                // petals are what give the character its actual size.
                let bodySize: CGSize = form.isDaisy ? CGSize(width: 100, height: 88) : CGSize(width: 260, height: 220)

                bodyShape
                    .fill(
                        RadialGradient(
                            colors: [colors.light, colors.dark],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(width: bodySize.width, height: bodySize.height)
                    .overlay(
                        bodyShape
                            .stroke(colors.stroke, lineWidth: 3)
                            .frame(width: bodySize.width, height: bodySize.height)
                    )

                if form.isDog {
                    dogFacePatch(bodyShape: bodyShape)
                } else if form.isCat {
                    catFacePatch(bodyShape: bodyShape)
                } else if form.hasPrincessDress {
                    princessBodyFill(bodyShape: bodyShape)
                } else if form.isApple {
                    appleShine
                } else if form.isTennisBall {
                    tennisSeams(bodyShape: bodyShape)
                } else if form.isSoccerBall {
                    soccerPattern(bodyShape: bodyShape)
                }
            }

            face(
                yOffset: form.isDonut ? -34 : -10,
                color: form.isSoccerBall ? Color.white : Color(red: 0.35, green: 0.24, blue: 0.05)
            )

            if form.hasBeard {
                beardAndMoustache
            }
            if form.isCat {
                whiskers
            }
            if form.hasSunglasses {
                coolSunglasses
            }

            if form.isDog {
                dogEars(colors: colors)
            } else if form.isCat {
                catEars
            } else if form.isPitcher {
                pitcherTrim(colors: colors)
            } else if form.isDonut {
                // The frosting cap already reads as the "top" detail —
                // no nub/leaf needed.
            } else if form.isTennisBall {
                // The seam pattern is the identifying detail — no nub/leaf.
            } else if form.isDaisy {
                // The petal ring already reads as the "top" detail.
            } else if form.isSoccerBall {
                // The pentagon pattern is the identifying detail — no nub/leaf.
            } else {
                if form.isApple {
                    stem(colors: colors)
                } else {
                    // little nub on top
                    Ellipse()
                        .fill(colors.stroke)
                        .frame(width: 14, height: 10)
                        .offset(y: -112)
                }

                if form.hasSharkFin {
                    sharkFin(colors: colors)
                } else if form.usesFlower {
                    flower
                } else {
                    leaf
                }

                // Worn askew, tilted off to the side, so it doesn't fight
                // the leaf for the same spot on top of the head.
                if form.hasPrincessDress {
                    tiara
                }
            }

            if form.hasSharkFin {
                sharkTail(colors: colors)
            }

            // Daisy's arms/legs are green (matching the leaf) rather than
            // the golden center's own stroke color.
            let limbColors = form.isDaisy ? (light: colors.light, dark: colors.dark, stroke: Color(red: 0.36, green: 0.62, blue: 0.24)) : colors
            arms(colors: limbColors)
            legs(colors: limbColors)

            if form.hasRunningShoes {
                runningShoes
            }
            if form.hasPrincessDress {
                princessDress
            }
        }
    }

    /// Not private: PreviewGallery.swift renders this directly (without the
    /// surrounding scene chrome) to preview individual forms at a glance.
    var lemonCharacter: some View {
        ZStack {
            characterBody(form: currentForm)
                .rotationEffect(.degrees(moveRotation + twirlRotation))

            if showBabyLemon {
                babyLemonCompanion
            }
        }
        .offset(moveOffset)
        .scaleEffect(moveScale)
    }

    private var leaf: some View {
        Ellipse()
            .fill(Color(red: 0.36, green: 0.62, blue: 0.24))
            .frame(width: 46, height: 22)
            .rotationEffect(.degrees(-30))
            .offset(x: 20, y: -118)
    }

    /// A short woody stem in place of the usual round nub, for Apple.
    private func stem(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        Capsule()
            .fill(colors.stroke)
            .frame(width: 8, height: 24)
            .rotationEffect(.degrees(-8))
            .offset(x: -4, y: -118)
    }

    /// A couple of glossy highlight streaks so the apple's skin reads as
    /// shiny rather than flat.
    private var appleShine: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.55))
                .frame(width: 16, height: 60)
                .rotationEffect(.degrees(-18))
                .offset(x: -58, y: -42)
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 8, height: 28)
                .rotationEffect(.degrees(-18))
                .offset(x: -34, y: -34)
        }
    }

    /// The white crossing seam lines, clipped to the body silhouette so
    /// they never spill past the outline.
    private func tennisSeams(bodyShape: AnyShape) -> some View {
        TennisSeamShape()
            .stroke(Color(red: 0.99, green: 0.93, blue: 0.9), style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .frame(width: 260, height: 220)
            .clipShape(bodyShape)
    }

    /// A central black pentagon surrounded by six touching panels — the
    /// classic soccer ball pattern, clipped to the body silhouette.
    private func soccerPattern(bodyShape: AnyShape) -> some View {
        let panelColor = Color(red: 0.14, green: 0.14, blue: 0.16)
        // Placed at the center pentagon's edge-midpoint angles so each
        // rotated petal nestles against a flat edge instead of a vertex.
        let petalAngles: [Double] = [-54, 18, 90, 162, 234]

        return ZStack {
            SoccerLinksShape()
                .stroke(panelColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 260, height: 220)
            PentagonShape()
                .fill(panelColor)
                .frame(width: 300, height: 300)
            ForEach(Array(petalAngles.enumerated()), id: \.offset) { _, angle in
                let radians = Angle(degrees: angle).radians
                PentagonShape()
                    .fill(panelColor)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(180))
                    .offset(x: 95 * cos(radians), y: 95 * sin(radians))
            }
        }
        .offset(y: -12)
        .frame(width: 260, height: 220)
        .clipShape(bodyShape)
    }

    private var flower: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Ellipse()
                    .fill(Color(red: 1.0, green: 0.75, blue: 0.85))
                    .frame(width: 16, height: 10)
                    .offset(x: 8)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            Circle()
                .fill(Color(red: 0.98, green: 0.78, blue: 0.1))
                .frame(width: 10, height: 10)
        }
        .offset(x: 20, y: -118)
    }

    /// A full ring of white petals radiating out from the center, drawn
    /// behind the body so only the outer portion of each petal peeks out
    /// past the golden-yellow "center" — turning the whole character into
    /// a daisy flower rather than just decorating one spot on it.
    private var daisyPetals: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Ellipse()
                    .fill(Color.white)
                    .overlay(Ellipse().stroke(Color(red: 0.15, green: 0.13, blue: 0.1), lineWidth: 4))
                    .frame(width: 56, height: 110)
                    .offset(y: -78)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
        }
        // Rotated petals report a larger implicit size to the layout system
        // than they actually need — pin this to the same footprint every
        // other form uses so it doesn't push the name label down.
        .frame(width: 260, height: 220)
    }

    /// Dark patch over one side of the head for Ruby's asymmetric coloring,
    /// clipped to the body silhouette so it never spills past the outline.
    /// Recolors the lower portion of the body pink, clipped to the body's
    /// own silhouette — starting at about the collar's middle and reaching
    /// down to the bottom — so the bare lemon color on the sides is simply
    /// filled in rather than covered with separate dress-shaped pieces.
    private func princessBodyFill(bodyShape: AnyShape) -> some View {
        Rectangle()
            .fill(Color(red: 1.0, green: 0.62, blue: 0.82))
            .frame(width: 260, height: 72)
            .frame(width: 260, height: 220, alignment: .bottom)
            .clipShape(bodyShape)
    }

    private func dogFacePatch(bodyShape: AnyShape) -> some View {
        Ellipse()
            .fill(Color(red: 0.55, green: 0.55, blue: 0.58))
            .frame(width: 150, height: 170)
            .offset(x: -55, y: -35)
            .frame(width: 260, height: 220)
            .clipShape(bodyShape)
    }

    private func dogEars(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        ZStack {
            Ellipse()
                .fill(colors.dark)
                .frame(width: 52, height: 92)
                .rotationEffect(.degrees(-18))
                .offset(x: -112, y: -66)
            Ellipse()
                .fill(colors.dark)
                .frame(width: 52, height: 92)
                .rotationEffect(.degrees(18))
                .offset(x: 112, y: -66)
        }
    }

    /// Black mask with a white blaze down the middle, clipped to the body silhouette.
    private func catFacePatch(bodyShape: AnyShape) -> some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                .frame(width: 220, height: 200)
                .offset(y: -20)
            Ellipse()
                .fill(Color.white)
                .frame(width: 38, height: 180)
                .offset(y: -6)
        }
        .frame(width: 260, height: 220)
        .clipShape(bodyShape)
    }

    private var catEars: some View {
        ZStack {
            Triangle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                .frame(width: 46, height: 56)
                .rotationEffect(.degrees(-8))
                .offset(x: -78, y: -108)
            Triangle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                .frame(width: 46, height: 56)
                .rotationEffect(.degrees(8))
                .offset(x: 78, y: -108)
        }
    }

    private var whiskers: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 44, height: 1.5)
                    .rotationEffect(.degrees(Double(i - 1) * 10))
                    .offset(x: -60, y: CGFloat(i - 1) * 7)
                Capsule()
                    .fill(Color.white.opacity(0.85))
                    .frame(width: 44, height: 1.5)
                    .rotationEffect(.degrees(-Double(i - 1) * 10))
                    .offset(x: 60, y: CGFloat(i - 1) * 7)
            }
        }
        .offset(y: 4)
    }

    /// Heart-shaped lenses over the eyes, with a small bridge and a couple
    /// of glossy highlights — what makes Cool Lemon cool.
    private var coolSunglasses: some View {
        let frame = Color(red: 1.0, green: 0.45, blue: 0.65)

        return ZStack {
            heartLens.offset(x: -28, y: -19)
            heartLens.offset(x: 28, y: -19)
            Capsule()
                .fill(frame)
                .frame(width: 14, height: 5)
                .offset(y: -21)
        }
    }

    private var heartLens: some View {
        HeartShape()
            .fill(Color.black)
            .overlay(HeartShape().stroke(Color(red: 1.0, green: 0.45, blue: 0.65), lineWidth: 3))
            .frame(width: 42, height: 37)
            .overlay(
                Capsule()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 6, height: 12)
                    .rotationEffect(.degrees(-20))
                    .offset(x: -7, y: -5)
            )
    }

    private var beardAndMoustache: some View {
        ZStack {
            // Chin beard, well clear of the mouth.
            Ellipse()
                .fill(Color(red: 0.4, green: 0.29, blue: 0.14))
                .frame(width: 68, height: 36)
                .offset(y: 33)
            // Moustache, sitting right above the mouth line.
            Capsule()
                .fill(Color(red: 0.4, green: 0.29, blue: 0.14))
                .frame(width: 20, height: 6)
                .rotationEffect(.degrees(-16))
                .offset(x: -12, y: -3)
            Capsule()
                .fill(Color(red: 0.4, green: 0.29, blue: 0.14))
                .frame(width: 20, height: 6)
                .rotationEffect(.degrees(16))
                .offset(x: 12, y: -3)
        }
        .offset(y: -10)
    }

    private func sharkFin(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        Triangle()
            .fill(colors.dark)
            .overlay(Triangle().stroke(colors.stroke, lineWidth: 2))
            .frame(width: 40, height: 50)
            .offset(y: -128)
    }

    private func sharkTail(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        Triangle()
            .fill(colors.dark)
            .overlay(Triangle().stroke(colors.stroke, lineWidth: 2))
            .frame(width: 34, height: 56)
            .rotationEffect(.degrees(100))
            .offset(x: 128, y: 10)
    }

    private var runningShoes: some View {
        ZStack {
            Capsule()
                .fill(Color.white)
                .frame(width: 24, height: 13)
                .overlay(Capsule().stroke(Color(red: 0.2, green: 0.45, blue: 0.85), lineWidth: 2.5))
                .offset(x: -23 + leftLegOffset.width, y: 119 + leftLegOffset.height)
            Capsule()
                .fill(Color.white)
                .frame(width: 24, height: 13)
                .overlay(Capsule().stroke(Color(red: 0.2, green: 0.45, blue: 0.85), lineWidth: 2.5))
                .offset(x: 23 + rightLegOffset.width, y: 119 + rightLegOffset.height)
            Capsule()
                .fill(Color(red: 0.85, green: 0.2, blue: 0.3))
                .frame(width: 60, height: 9)
                .offset(y: -84)
        }
    }

    /// Silver rather than gold so it reads clearly against the yellow head
    /// instead of blending into it. Tilted and shifted aside — rather than
    /// centered — so it doesn't fight the leaf for the same spot on top.
    private var tiara: some View {
        ZStack {
            tiaraPoint(width: 13, height: 16).offset(x: -15, y: -114)
            tiaraPoint(width: 17, height: 22).offset(y: -118)
            tiaraPoint(width: 13, height: 16).offset(x: 15, y: -114)
            Circle()
                .fill(Color(red: 0.9, green: 0.25, blue: 0.55))
                .frame(width: 7, height: 7)
                .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1))
                .offset(y: -120)
        }
        .rotationEffect(.degrees(-16))
        .offset(x: -22, y: 6)
    }

    private func tiaraPoint(width: CGFloat, height: CGFloat) -> some View {
        Triangle()
            .fill(Color(red: 0.93, green: 0.94, blue: 0.98))
            .overlay(Triangle().stroke(Color(red: 0.6, green: 0.63, blue: 0.7), lineWidth: 1.5))
            .frame(width: width, height: height)
    }

    /// Pink medieval-princess look: puffed shoulder sleeves worn over the
    /// arms, a scalloped collar, and a full belled skirt with a ruffled hem
    /// — rather than a single flat triangle standing in for the whole dress.
    /// Colored to match a reference sketch: pink sleeves and skirt sides,
    /// a white collar and skirt center panel, and a blue gem at the collar.
    private var princessDress: some View {
        let pink = Color(red: 1.0, green: 0.62, blue: 0.82)
        let white = Color(red: 0.99, green: 0.98, blue: 0.99)
        let trim = Color(red: 0.85, green: 0.4, blue: 0.62)
        let jewelBlue = Color(red: 0.3, green: 0.55, blue: 0.88)

        return ZStack {
            Circle()
                .fill(pink)
                .overlay(Circle().stroke(trim, lineWidth: 2))
                .frame(width: 50, height: 50)
                .offset(x: -116, y: -30)
            Circle()
                .fill(pink)
                .overlay(Circle().stroke(trim, lineWidth: 2))
                .frame(width: 50, height: 50)
                .offset(x: 116, y: -30)

            // Collar: curved, and wide enough to read as connected to the
            // sleeves — the body's own bare-lemon color is filled in pink
            // below this (see `princessBodyFill`), so there's no gap left
            // to bridge with a separate shape. Sits well clear of the mouth.
            Ellipse()
                .fill(white)
                .overlay(Ellipse().stroke(trim, lineWidth: 2.5))
                .frame(width: 140, height: 50)
                .offset(y: 38)

            // Skirt, now entirely white.
            PrincessSkirtShape()
                .fill(white)
                .overlay(PrincessSkirtShape().stroke(trim, lineWidth: 2.5))
                .frame(width: 180, height: 100)
                .offset(y: 106)

            Circle()
                .fill(jewelBlue)
                .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 1))
                .frame(width: 10, height: 10)
                .offset(y: 18)
        }
    }

    /// A smaller lemon character that rides along after Baby Lemon is
    /// discovered. Reuses `characterBody(form:)` — the exact same body,
    /// face, decorations, arms and legs as the main character — scaled
    /// down as a whole, so it's always an exact miniature of whatever form
    /// the main lemon currently is (including any forms added later) and
    /// mirrors every dance, flex, and twirl in sync. The whole-body moves
    /// (jumps, spins, the wake pulse) already apply automatically since
    /// this view is a child inside `lemonCharacter`'s transformed group.
    private var babyLemonCompanion: some View {
        characterBody(form: currentForm)
            .rotationEffect(.degrees(moveRotation + twirlRotation))
            .scaleEffect(0.34)
            .offset(x: 95, y: 78)
    }

    /// The pitcher's body: lemonade filling the lower two-thirds, a pale
    /// translucent glass sheen over the whole silhouette so both the liquid
    /// and the empty headspace above it read as glass, and a couple of
    /// diagonal highlight streaks for the reflection.
    private func pitcherGlassBody(colors: (light: Color, dark: Color, stroke: Color), bodyShape: AnyShape) -> some View {
        ZStack {
            bodyShape
                .fill(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.93, blue: 0.45), Color(red: 0.95, green: 0.76, blue: 0.14)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 260, height: 220)
                .mask(
                    Rectangle()
                        .frame(width: 260, height: 220 * 0.62)
                        .frame(width: 260, height: 220, alignment: .bottom)
                )

            // A couple of bubbles rising through the liquid.
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 7, height: 7)
                .offset(x: -28, y: 40)
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 5, height: 5)
                .offset(x: 22, y: 68)

            bodyShape
                .fill(
                    LinearGradient(
                        colors: [colors.light.opacity(0.55), colors.dark.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 260, height: 220)

            glassHighlight
                .frame(width: 260, height: 220)
                .clipShape(bodyShape)

            bodyShape
                .stroke(colors.stroke, lineWidth: 3)
                .frame(width: 260, height: 220)
        }
    }

    /// Two diagonal streaks standing in for a glass reflection.
    private var glassHighlight: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.45))
                .frame(width: 14, height: 120)
                .rotationEffect(.degrees(18))
                .offset(x: -55, y: -10)
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 8, height: 70)
                .rotationEffect(.degrees(18))
                .offset(x: -30, y: 20)
        }
    }

    /// Handle loop, stroked twice so it reads as an outlined band.
    private func pitcherHandle(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        ZStack {
            PitcherHandleShape()
                .stroke(colors.stroke, style: StrokeStyle(lineWidth: 24, lineCap: .butt))
                .frame(width: 260, height: 220)
            PitcherHandleShape()
                .stroke(colors.light, style: StrokeStyle(lineWidth: 18, lineCap: .butt))
                .frame(width: 260, height: 220)
        }
    }

    /// Rim, spout and the lemonade sitting in it.
    private func pitcherTrim(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        ZStack {
            PitcherRimShape()
                .fill(colors.dark)
                .frame(width: 218, height: 34)
                .overlay(
                    PitcherRimShape()
                        .stroke(colors.stroke, lineWidth: 3)
                        .frame(width: 218, height: 34)
                )
                .offset(x: 13, y: -88)

            // The lemonade itself.
            PitcherRimShape()
                .fill(Color(red: 1.0, green: 0.93, blue: 0.5))
                .frame(width: 180, height: 20)
                .offset(x: 6, y: -88)

            // A couple of bubbles floating on top.
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 9, height: 9)
                .offset(x: -46, y: -90)
            Circle()
                .fill(Color.white.opacity(0.65))
                .frame(width: 6, height: 6)
                .offset(x: 14, y: -86)
        }
    }

    /// Strawberry-frosted donut: a baked-dough ring with a punched-out
    /// hole, a drippy frosting cap on top, and a scatter of sprinkles.
    private func donutBody(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        // Baked-dough tones for the rim that peeks out past the frosting.
        let doughLight = Color(red: 0.94, green: 0.78, blue: 0.56)
        let doughDark = Color(red: 0.85, green: 0.63, blue: 0.4)
        let frostingShine = Color(red: 1.0, green: 0.85, blue: 0.9)
        let sprinkleColors: [Color] = [
            Color(red: 0.98, green: 0.78, blue: 0.15),
            Color(red: 0.35, green: 0.65, blue: 0.95),
            Color(red: 0.55, green: 0.8, blue: 0.35),
            Color(red: 0.95, green: 0.95, blue: 0.98),
            Color(red: 0.65, green: 0.4, blue: 0.85)
        ]
        // Spread across the frosted area, steering clear of the face
        // (upper middle), the hole (lower middle), and the bare dough rim
        // now showing around the outer edge.
        let sprinkles: [(x: CGFloat, y: CGFloat, angle: Double, color: Int)] = [
            (-70, -64, 15, 0), (-44, -74, -25, 1), (0, -78, 50, 2), (40, -72, -10, 3), (70, -60, 30, 4),
            (-82, -28, 60, 2), (-76, 8, -30, 0), (-64, 42, 20, 3), (-38, 66, -45, 1), (0, 70, 35, 4),
            (38, 67, -20, 0), (64, 45, 40, 2), (76, 10, -15, 3), (80, -26, 25, 1),
            (-22, -53, 10, 4), (22, -51, -35, 0), (50, 16, 50, 1), (-50, 19, -10, 3)
        ]
        return ZStack {
            // Dough base, full size — this is what shows at the outer rim.
            DonutShape()
                .fill(
                    RadialGradient(colors: [doughLight, doughDark], center: .center, startRadius: 10, endRadius: 160),
                    style: FillStyle(eoFill: true)
                )
                .frame(width: 260, height: 220)
                .overlay(
                    DonutShape()
                        .stroke(colors.stroke, lineWidth: 3)
                        .frame(width: 260, height: 220)
                )

            // Frosting, inset from the outer edge so a ring of dough shows
            // around it — the hole stays anchored to the same spot as the
            // dough base's hole since `outerInset` only shrinks the outside.
            DonutShape(outerInset: 20)
                .fill(
                    RadialGradient(colors: [colors.light, colors.dark], center: .center, startRadius: 10, endRadius: 160),
                    style: FillStyle(eoFill: true)
                )
                .frame(width: 260, height: 220)
                .overlay(
                    DonutShape(outerInset: 20)
                        .stroke(colors.stroke.opacity(0.7), lineWidth: 2)
                        .frame(width: 260, height: 220)
                )

            // Shine streak on the frosting.
            Capsule()
                .fill(frostingShine.opacity(0.7))
                .frame(width: 10, height: 36)
                .rotationEffect(.degrees(-20))
                .offset(x: -52, y: -68)

            ForEach(Array(sprinkles.enumerated()), id: \.offset) { _, sprinkle in
                Capsule()
                    .fill(sprinkleColors[sprinkle.color])
                    .frame(width: 14, height: 4)
                    .rotationEffect(.degrees(sprinkle.angle))
                    .offset(x: sprinkle.x, y: sprinkle.y)
            }
        }
    }

    private var partyLights: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(Color(hue: Double(i) / 12.0, saturation: 0.85, brightness: 0.95))
                    .frame(width: 16, height: 16)
                    .offset(lightOffset(for: i))
                    .scaleEffect(lightsLit ? 1 : 0.2)
                    .opacity(lightsLit ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.35)
                            .repeatCount(6, autoreverses: true)
                            .delay(Double(i) * 0.04),
                        value: lightsLit
                    )
            }
        }
    }

    private func lightOffset(for index: Int) -> CGSize {
        let angle = Double(index) / 12.0 * 2 * .pi
        let radius = 175.0
        return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }

    private func face(yOffset: CGFloat = -10, color: Color = Color(red: 0.35, green: 0.24, blue: 0.05)) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 36) {
                eye(color: color)
                eye(color: color)
            }
            mouth(color: color)
        }
        .offset(y: yOffset)
    }

    private func eye(color: Color) -> some View {
        Group {
            if isAwake {
                Circle()
                    .fill(color)
                    .frame(width: 14, height: 14)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 16, height: 3)
            }
        }
    }

    private func mouth(color: Color) -> some View {
        Group {
            if isAwake {
                Capsule()
                    .fill(color)
                    .frame(width: 34, height: 6)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
        }
    }

    private func arms(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        ZStack {
            arm(angle: leftArmAngle, forearmAngle: leftForearmAngle, side: -1, colors: colors)
                .offset(x: -118, y: -8)
            arm(angle: rightArmAngle, forearmAngle: rightForearmAngle, side: 1, colors: colors)
                .offset(x: 118, y: -8)
        }
    }

    /// One arm, hanging from a shoulder pivot at the top of its 12x56 layout box.
    /// `angle` swings the whole arm at the shoulder, `forearmAngle` bends it at the elbow.
    /// `side` is -1 for the left arm and 1 for the right, so the bicep bulges outward.
    /// `colors` is passed in (rather than read from `currentForm`) so `babyLemonCompanion`
    /// can reuse this exact geometry with fixed lemon colors while mirroring the same
    /// angle/muscle state as the main character's arms.
    private func arm(angle: Double, forearmAngle: Double, side: Double, colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        VStack(spacing: 0) {
            // Upper arm.
            ZStack {
                Capsule()
                    .fill(colors.stroke)
                    .frame(width: 12, height: 34)

                if showMuscles {
                    bicep(side: side, colors: colors)
                }
            }
            .frame(width: 12, height: 34)

            // Forearm, overlapping the upper arm by 4pt so a straight arm reads as one capsule.
            ZStack {
                Capsule()
                    .fill(colors.stroke)
                    .frame(width: 12, height: 30)

                if showMuscles {
                    Circle()
                        .fill(colors.dark)
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(colors.stroke, lineWidth: 3))
                        .offset(y: 15)
                }
            }
            .frame(width: 12, height: 22)
            .rotationEffect(.degrees(forearmAngle), anchor: .top)
        }
        .frame(width: 12, height: 56)
        // Beefed up while flexing. Scaled about the shoulder so the arm stays attached.
        .scaleEffect(showMuscles ? 1.45 : 1, anchor: .top)
        .rotationEffect(.degrees(angle), anchor: .top)
    }

    /// Cartoon bicep bulge that pops onto the upper arm during the flex.
    private func bicep(side: Double, colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        ZStack {
            Ellipse()
                .fill(colors.dark)
                .frame(width: 42, height: 34)
                .overlay(Ellipse().stroke(colors.stroke, lineWidth: 3))

            // Crease line so it reads as a flexed muscle rather than a blob.
            Capsule()
                .fill(colors.stroke.opacity(0.55))
                .frame(width: 3, height: 13)
                .rotationEffect(.degrees(18 * side))
                .offset(x: CGFloat(side * 8))
        }
        // Positive local x is the underside of the arm once it is swung out for
        // the flex, so the bulge is offset toward `side` to sit on top.
        .offset(x: CGFloat(side * 9), y: 2)
        .transition(.scale(scale: 0.2).combined(with: .opacity))
    }

    private func legs(colors: (light: Color, dark: Color, stroke: Color)) -> some View {
        ZStack {
            Capsule()
                .fill(colors.stroke)
                .frame(width: 10, height: 26)
                .offset(x: -23 + leftLegOffset.width, y: 105 + leftLegOffset.height)
            Capsule()
                .fill(colors.stroke)
                .frame(width: 10, height: 26)
                .offset(x: 23 + rightLegOffset.width, y: 105 + rightLegOffset.height)
        }
    }

    private var dpad: some View {
        VStack(spacing: 4) {
            danceButton(.up)
            HStack(spacing: 4) {
                danceButton(.left)
                Color.clear.frame(width: 44, height: 44)
                danceButton(.right)
            }
            danceButton(.down)
        }
    }

    private func danceButton(_ direction: DanceDirection) -> some View {
        Button {
            dance(direction)
        } label: {
            Image(systemName: direction.symbolName)
                .font(.system(size: 40))
                .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.05))
        }
        .buttonStyle(.plain)
    }

    private var twirlButton: some View {
        Button {
            twirl()
        } label: {
            Label("Twirl!", systemImage: "sparkles")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.6),
                                Color(red: 0.6, green: 0.4, blue: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
    }

    /// Plays a melody one note at a time, `step` seconds apart.
    private func playTune(_ tune: [Double], step: Double = 0.15, duration: Double = 0.17) {
        for (i, frequency) in tune.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * step) {
                synth.play(frequency: frequency, duration: duration)
            }
        }
    }

    private func wake() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.45)) {
            isAwake = true
            wakePulse = 1.12
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.12)) {
            wakePulse = 1
        }
        synth.play(frequency: 440)
    }

    private func dance(_ direction: DanceDirection) {
        guard !isBusy else { return }

        if let kind = recordInput(.direction(direction)) {
            trigger(kind)
            return
        }

        isBusy = true
        let arms = direction.armAngles
        let legs = direction.legOffsets

        withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) {
            moveOffset = direction.offset
            moveRotation = direction.rotation
            moveScale = direction.squash
            leftArmAngle = arms.left
            rightArmAngle = arms.right
            leftLegOffset = legs.left
            rightLegOffset = legs.right
        }
        synth.play(frequency: direction.frequency)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            isBusy = false
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                moveOffset = .zero
                moveRotation = 0
                moveScale = CGSize(width: 1, height: 1)
                leftArmAngle = -20
                rightArmAngle = 20
                leftLegOffset = .zero
                rightLegOffset = .zero
            }
        }
    }

    private func twirl() {
        guard !isBusy else { return }

        if let kind = recordInput(.twirl) {
            trigger(kind)
            return
        }

        isBusy = true
        withAnimation(.easeInOut(duration: 1.2)) {
            twirlRotation += 720
            leftArmAngle = -150
            rightArmAngle = 150
        }
        lightsLit.toggle()

        playTune(Tune.twirl, step: 0.15, duration: 0.17)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                leftArmAngle = -20
                rightArmAngle = 20
            }
            isBusy = false
        }
    }

    /// Appends to the rolling input buffer and reports the combo it completes, if any.
    private func recordInput(_ action: InputAction) -> ComboKind? {
        inputHistory.append(action)
        let candidates = ComboCatalog.reachable()
        let maxLength = candidates.map { $0.sequence.count }.max() ?? 0
        if inputHistory.count > maxLength {
            inputHistory.removeFirst(inputHistory.count - maxLength)
        }
        guard let combo = Self.matchingCombo(history: inputHistory, in: candidates) else {
            return nil
        }
        inputHistory.removeAll()
        ComboDiscovery.markDiscovered(combo.id)
        return combo.kind
    }

    /// The pure matching step behind `recordInput`, split out so tests can
    /// exercise it without a live view and its `@State`. Returns the first
    /// candidate whose sequence matches the tail of `history` — so a combo
    /// whose sequence is a suffix of another's will shadow it entirely.
    static func matchingCombo(history: [InputAction], in candidates: [ComboDefinition]) -> ComboDefinition? {
        for combo in candidates {
            guard history.count >= combo.sequence.count else { continue }
            if Array(history.suffix(combo.sequence.count)) == combo.sequence {
                return combo
            }
        }
        return nil
    }

    private func trigger(_ kind: ComboKind) {
        switch kind {
        case .lemonPower: performSpecialMove()
        case .transform(let fruit): performTransform(fruit)
        case .flex: performFlex()
        case .addBabyLemon: performAddBabyLemon()
        }
    }

    private func performSpecialMove() {
        isBusy = true
        let duration = 2.2
        currentForm = .lemon
        showBabyLemon = false
        bannerText = Fruit.lemon.bannerText

        withAnimation(.easeInOut(duration: 0.3)) {
            showBanner = true
        }
        withAnimation(.interpolatingSpring(stiffness: 55, damping: 6)) {
            twirlRotation += 1080
            moveScale = CGSize(width: 1.3, height: 1.3)
        }
        withAnimation(.easeInOut(duration: 0.35).delay(duration - 0.35)) {
            moveScale = CGSize(width: 1, height: 1)
        }
        lightsLit.toggle()

        let keyframes: [(left: Double, right: Double, legs: Bool)] = [
            (-160, 160, true), (-40, 40, false), (-160, 160, true), (-40, 40, false), (-20, 20, true)
        ]
        for (i, keyframe) in keyframes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                    leftArmAngle = keyframe.left
                    rightArmAngle = keyframe.right
                    leftLegOffset = keyframe.legs ? CGSize(width: -14, height: -8) : CGSize(width: 14, height: -8)
                    rightLegOffset = keyframe.legs ? CGSize(width: 14, height: -8) : CGSize(width: -14, height: -8)
                }
            }
        }

        playTune(Fruit.lemon.tune, step: 0.13, duration: 0.15)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                leftArmAngle = -20
                rightArmAngle = 20
                leftLegOffset = .zero
                rightLegOffset = .zero
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                showBanner = false
            }
            isBusy = false
        }
    }

    private func performTransform(_ fruit: Fruit) {
        isBusy = true
        let duration = 2.0
        currentForm = fruit
        bannerText = fruit.bannerText

        withAnimation(.easeInOut(duration: 0.3)) {
            showBanner = true
        }
        withAnimation(.interpolatingSpring(stiffness: 60, damping: 7)) {
            twirlRotation += 720
            moveScale = CGSize(width: 1.2, height: 1.2)
        }
        withAnimation(.easeInOut(duration: 0.3).delay(duration - 0.3)) {
            moveScale = CGSize(width: 1, height: 1)
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            leftArmAngle = -140
            rightArmAngle = 140
        }
        lightsLit.toggle()

        playTune(fruit.tune, step: 0.16, duration: 0.18)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                leftArmAngle = -20
                rightArmAngle = 20
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                showBanner = false
            }
            isBusy = false
        }
    }

    private func performAddBabyLemon() {
        isBusy = true
        let duration = 1.4
        bannerText = "👶 BABY! 👶"
        showBabyLemon = true

        withAnimation(.easeInOut(duration: 0.3)) {
            showBanner = true
        }
        withAnimation(.interpolatingSpring(stiffness: 70, damping: 8)) {
            moveScale = CGSize(width: 1.15, height: 1.15)
        }
        withAnimation(.easeInOut(duration: 0.3).delay(duration - 0.3)) {
            moveScale = CGSize(width: 1, height: 1)
        }
        lightsLit.toggle()

        playTune(Tune.babyLemon, step: 0.14, duration: 0.16)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showBanner = false
            }
            isBusy = false
        }
    }

    private func performFlex() {
        isBusy = true
        let duration = 1.6
        bannerText = "💪 STRONG \(currentForm.name.uppercased())! 💪"

        withAnimation(.easeInOut(duration: 0.3)) {
            showBanner = true
        }
        // Double-biceps pose. Unlike the dance poses these angles are mirrored
        // (positive on the left), which swings the upper arms outward away from
        // the body instead of across it; the forearms then fold back up over the
        // biceps.
        withAnimation(.spring(response: 0.3, dampingFraction: 0.35)) {
            leftArmAngle = 125
            rightArmAngle = -125
            leftForearmAngle = 75
            rightForearmAngle = -75
            showMuscles = true
            moveScale = CGSize(width: 1.15, height: 0.95)
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4).delay(0.5)) {
            moveScale = CGSize(width: 1, height: 1)
        }
        playTune(Tune.flex, step: 0.3, duration: 0.32)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                leftArmAngle = -20
                rightArmAngle = 20
                leftForearmAngle = 0
                rightForearmAngle = 0
                showMuscles = false
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                showBanner = false
            }
            isBusy = false
        }
    }
}

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var discoveryRefresh = false
    @State private var showResetConfirmation = false

    /// The revealed steps followed by a "❔" placeholder for each step the
    /// player hasn't spent a hint tap on yet.
    private func partialSequence(_ hint: ComboDefinition, revealedCount: Int) -> String {
        let shown = Array(hint.hintSteps.prefix(revealedCount))
        let hidden = Array(repeating: "❔", count: hint.pressCount - revealedCount)
        return (shown + hidden).joined(separator: " ")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to Play")
                            .font(.title2.weight(.bold))
                        Text("Tap the sleepy lemon to wake it up. Use the arrows and twirl button to make it dance.")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Secret Combos")
                            .font(.title2.weight(.bold))
                        Text("The lemon is hiding secret combos in its dance moves. Do the right sequence to unlock something special. Here's the first one to get you started. Combos you've found will show up here.")
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(ComboCatalog.reachable()) { hint in
                            let discovered = hint.alwaysRevealed || ComboDiscovery.isDiscovered(hint.id)
                            let hintCount = ComboDiscovery.hintCount(hint.id)
                            let revealed = discovered || hintCount >= hint.pressCount
                            HStack(alignment: .top, spacing: 12) {
                                Text(hint.emoji)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hint.name)
                                        .font(.headline)
                                    Text(revealed ? hint.fullSequence : (hintCount == 0 ? "??? · \(hint.pressCount) presses" : partialSequence(hint, revealedCount: hintCount)))
                                        .font(.subheadline)
                                        .foregroundStyle(revealed ? Color(red: 0.55, green: 0.42, blue: 0.05) : Color(red: 0.55, green: 0.42, blue: 0.05).opacity(0.6))

                                    if !revealed {
                                        Button {
                                            ComboDiscovery.revealNextHint(hint.id, total: hint.pressCount)
                                            discoveryRefresh.toggle()
                                        } label: {
                                            Text("💡 Hint (\(hintCount)/\(hint.pressCount))")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(red: 0.85, green: 0.58, blue: 0.05), in: Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .id(discoveryRefresh)

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset Found Combos", systemImage: "arrow.counterclockwise")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.top, 8)
                }
                .padding()
                .foregroundStyle(Color(red: 0.35, green: 0.24, blue: 0.05))
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.92))
            .navigationTitle("It's a Lemon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            // SwiftUI will not re-render just because the clock crossed into
            // an event's window, so recompute when the app comes forward.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { discoveryRefresh.toggle() }
            }
            .confirmationDialog(
                "Forget every combo you've found?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    for hint in ComboCatalog.all where !hint.alwaysRevealed {
                        ComboDiscovery.reset(hint.id)
                    }
                    discoveryRefresh.toggle()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

#Preview {
    ContentView()
}
