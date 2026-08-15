import SwiftUI

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

/// Short melodies for the special moves, as note frequencies in Hz.
/// Played one note at a time through `ToneSynth`'s sine wave.
enum Tune {
    /// Rising "ta-daa!" fanfare — LEMON POWER.
    static let lemonPower: [Double] = [523.25, 523.25, 523.25, 659.25, 783.99, 1046.50, 783.99, 1046.50, 1318.51]
    /// "Twinkle, Twinkle, Little Star" — Clementine.
    static let clementine: [Double] = [523.25, 523.25, 783.99, 783.99, 880.00, 880.00, 783.99]
    /// "Frere Jacques" — Lime.
    static let lime: [Double] = [523.25, 587.33, 659.25, 523.25, 523.25, 587.33, 659.25, 523.25]
    /// "Mary Had a Little Lamb" — Lemonade Pitcher.
    static let lemonadePitcher: [Double] = [659.25, 587.33, 523.25, 587.33, 659.25, 659.25, 659.25]
    /// Big slow C-G-C-E strongman fanfare — STRONG LEMON flex.
    static let flex: [Double] = [261.63, 392.00, 523.25, 659.25]
    /// Sparkle run for the plain twirl button.
    static let twirl: [Double] = [523.25, 659.25, 783.99, 1046.50, 783.99, 659.25, 880.00, 1046.50]
}

enum Fruit: Equatable {
    case lemon, clementine, lime, lemonadePitcher

    var bodyColors: (light: Color, dark: Color, stroke: Color) {
        switch self {
        case .lemon:
            return (Color(red: 1.0, green: 0.93, blue: 0.35), Color(red: 0.98, green: 0.78, blue: 0.1), Color(red: 0.75, green: 0.58, blue: 0.05))
        case .clementine:
            return (Color(red: 1.0, green: 0.68, blue: 0.32), Color(red: 0.95, green: 0.48, blue: 0.12), Color(red: 0.75, green: 0.35, blue: 0.05))
        case .lime:
            return (Color(red: 0.78, green: 0.92, blue: 0.42), Color(red: 0.55, green: 0.78, blue: 0.22), Color(red: 0.32, green: 0.5, blue: 0.1))
        case .lemonadePitcher:
            return (Color(red: 0.97, green: 0.92, blue: 0.7), Color(red: 0.9, green: 0.78, blue: 0.35), Color(red: 0.7, green: 0.55, blue: 0.15))
        }
    }

    var usesFlower: Bool { self == .clementine }
    var isPitcher: Bool { self == .lemonadePitcher }

    var name: String {
        switch self {
        case .lemon: return "Lemon"
        case .clementine: return "Clementine"
        case .lime: return "Lime"
        case .lemonadePitcher: return "Lemonade Pitcher"
        }
    }

    /// Each form gets its own melody so the combos are told apart by ear.
    var tune: [Double] {
        switch self {
        case .lemon: return Tune.lemonPower
        case .clementine: return Tune.clementine
        case .lime: return Tune.lime
        case .lemonadePitcher: return Tune.lemonadePitcher
        }
    }

    var bannerText: String {
        switch self {
        case .lemon: return "🍋 LEMON POWER! 🍋"
        case .clementine: return "🍊 CLEMENTINE TIME! 🍊"
        case .lime: return "🍋‍🟩 LIME TIME! 🍋‍🟩"
        case .lemonadePitcher: return "🥤 LEMONADE TIME! 🥤"
        }
    }
}

enum ComboKind {
    case lemonPower
    case transform(Fruit)
    case flex
}

struct Combo {
    let sequence: [InputAction]
    let kind: ComboKind
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

    private let synth = ToneSynth()

    private let combos: [Combo] = [
        Combo(sequence: [.direction(.up), .direction(.up), .direction(.down), .direction(.down), .direction(.right), .direction(.right), .twirl], kind: .lemonPower),
        Combo(sequence: [.direction(.up), .direction(.up), .direction(.down), .direction(.down), .direction(.left), .direction(.left), .twirl], kind: .transform(.clementine)),
        Combo(sequence: [.direction(.down), .direction(.down), .direction(.up), .direction(.up), .direction(.left), .direction(.left), .twirl], kind: .flex),
        Combo(sequence: [.direction(.down), .direction(.down), .direction(.up), .direction(.up), .direction(.right), .direction(.right), .twirl], kind: .transform(.lime)),
        Combo(sequence: [.direction(.left), .direction(.left), .direction(.right), .direction(.right), .direction(.up), .direction(.up), .twirl], kind: .transform(.lemonadePitcher))
    ]

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.92)
                .ignoresSafeArea()

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
        }
    }

    private var bodyShape: AnyShape {
        currentForm.isPitcher ? AnyShape(PitcherShape()) : AnyShape(LemonShape())
    }

    private var lemonCharacter: some View {
        let colors = currentForm.bodyColors
        return ZStack {
            // Behind the body so the handle's joints are hidden by the wall.
            if currentForm.isPitcher {
                pitcherHandle
            }

            bodyShape
                .fill(
                    RadialGradient(
                        colors: [colors.light, colors.dark],
                        center: .center,
                        startRadius: 10,
                        endRadius: 160
                    )
                )
                .frame(width: 260, height: 220)
                .overlay(
                    bodyShape
                        .stroke(colors.stroke, lineWidth: 3)
                        .frame(width: 260, height: 220)
                )

            face

            if currentForm.isPitcher {
                pitcherTrim
            } else {
                // little nub on top
                Ellipse()
                    .fill(colors.stroke)
                    .frame(width: 14, height: 10)
                    .offset(y: -112)

                if currentForm.usesFlower {
                    flower
                } else {
                    leaf
                }
            }

            arms
            legs
        }
        .offset(moveOffset)
        .rotationEffect(.degrees(moveRotation + twirlRotation))
        .scaleEffect(moveScale)
    }

    private var leaf: some View {
        Ellipse()
            .fill(Color(red: 0.36, green: 0.62, blue: 0.24))
            .frame(width: 46, height: 22)
            .rotationEffect(.degrees(-30))
            .offset(x: 20, y: -118)
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

    /// Handle loop, stroked twice so it reads as an outlined band.
    private var pitcherHandle: some View {
        let colors = currentForm.bodyColors
        return ZStack {
            PitcherHandleShape()
                .stroke(colors.stroke, style: StrokeStyle(lineWidth: 24, lineCap: .butt))
                .frame(width: 260, height: 220)
            PitcherHandleShape()
                .stroke(colors.light, style: StrokeStyle(lineWidth: 18, lineCap: .butt))
                .frame(width: 260, height: 220)
        }
    }

    /// Rim, spout and the lemonade sitting in it.
    private var pitcherTrim: some View {
        let colors = currentForm.bodyColors
        return ZStack {
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

    private var face: some View {
        VStack(spacing: 10) {
            HStack(spacing: 36) {
                eye
                eye
            }
            mouth
        }
        .offset(y: -10)
    }

    private var eye: some View {
        Group {
            if isAwake {
                Circle()
                    .fill(Color(red: 0.35, green: 0.24, blue: 0.05))
                    .frame(width: 14, height: 14)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.35, green: 0.24, blue: 0.05))
                    .frame(width: 16, height: 3)
            }
        }
    }

    private var mouth: some View {
        Group {
            if isAwake {
                Capsule()
                    .fill(Color(red: 0.35, green: 0.24, blue: 0.05))
                    .frame(width: 34, height: 6)
            } else {
                Circle()
                    .fill(Color(red: 0.35, green: 0.24, blue: 0.05))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var arms: some View {
        ZStack {
            arm(angle: leftArmAngle, forearmAngle: leftForearmAngle, side: -1)
                .offset(x: -118, y: -8)
            arm(angle: rightArmAngle, forearmAngle: rightForearmAngle, side: 1)
                .offset(x: 118, y: -8)
        }
    }

    /// One arm, hanging from a shoulder pivot at the top of its 12x56 layout box.
    /// `angle` swings the whole arm at the shoulder, `forearmAngle` bends it at the elbow.
    /// `side` is -1 for the left arm and 1 for the right, so the bicep bulges outward.
    private func arm(angle: Double, forearmAngle: Double, side: Double) -> some View {
        let colors = currentForm.bodyColors
        return VStack(spacing: 0) {
            // Upper arm.
            ZStack {
                Capsule()
                    .fill(colors.stroke)
                    .frame(width: 12, height: 34)

                if showMuscles {
                    bicep(side: side)
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
    private func bicep(side: Double) -> some View {
        let colors = currentForm.bodyColors
        return ZStack {
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

    private var legs: some View {
        ZStack {
            Capsule()
                .fill(currentForm.bodyColors.stroke)
                .frame(width: 10, height: 26)
                .offset(x: -23 + leftLegOffset.width, y: 105 + leftLegOffset.height)
            Capsule()
                .fill(currentForm.bodyColors.stroke)
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
        let maxLength = combos.map { $0.sequence.count }.max() ?? 0
        if inputHistory.count > maxLength {
            inputHistory.removeFirst(inputHistory.count - maxLength)
        }
        for combo in combos {
            guard inputHistory.count >= combo.sequence.count else { continue }
            if Array(inputHistory.suffix(combo.sequence.count)) == combo.sequence {
                inputHistory.removeAll()
                return combo.kind
            }
        }
        return nil
    }

    private func trigger(_ kind: ComboKind) {
        switch kind {
        case .lemonPower: performSpecialMove()
        case .transform(let fruit): performTransform(fruit)
        case .flex: performFlex()
        }
    }

    private func performSpecialMove() {
        isBusy = true
        let duration = 2.2
        currentForm = .lemon
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

    private func performFlex() {
        isBusy = true
        let duration = 1.6
        bannerText = "💪 STRONG LEMON! 💪"

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

#Preview {
    ContentView()
}
