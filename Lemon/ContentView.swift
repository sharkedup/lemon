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

enum DanceDirection: CaseIterable {
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
}

struct ContentView: View {
    @State private var isAwake = false
    @State private var moveOffset: CGSize = .zero
    @State private var moveRotation: Double = 0
    @State private var moveScale: CGSize = CGSize(width: 1, height: 1)
    @State private var wakePulse: CGFloat = 1

    private let synth = ToneSynth()

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.92)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                lemonCharacter
                    .scaleEffect(wakePulse)
                    .onTapGesture {
                        guard !isAwake else { return }
                        wake()
                    }

                Text(isAwake ? "Lemon" : "Tap to wake up")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.55, green: 0.42, blue: 0.05))

                Spacer()

                if isAwake {
                    dpad
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        .padding(.bottom, 40)
                }
            }
        }
    }

    private var lemonCharacter: some View {
        ZStack {
            LemonShape()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.93, blue: 0.35), Color(red: 0.98, green: 0.78, blue: 0.1)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 160
                    )
                )
                .frame(width: 260, height: 220)
                .overlay(
                    LemonShape()
                        .stroke(Color(red: 0.75, green: 0.58, blue: 0.05), lineWidth: 3)
                        .frame(width: 260, height: 220)
                )

            face

            // little nub on top
            Ellipse()
                .fill(Color(red: 0.75, green: 0.58, blue: 0.05))
                .frame(width: 14, height: 10)
                .offset(y: -112)

            // leaf
            Ellipse()
                .fill(Color(red: 0.36, green: 0.62, blue: 0.24))
                .frame(width: 46, height: 22)
                .rotationEffect(.degrees(-30))
                .offset(x: 20, y: -118)

            legs
        }
        .offset(moveOffset)
        .rotationEffect(.degrees(moveRotation))
        .scaleEffect(moveScale)
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

    private var legs: some View {
        HStack(spacing: 26) {
            Capsule()
                .fill(Color(red: 0.75, green: 0.58, blue: 0.05))
                .frame(width: 10, height: 26)
            Capsule()
                .fill(Color(red: 0.75, green: 0.58, blue: 0.05))
                .frame(width: 10, height: 26)
        }
        .offset(y: 105)
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
        withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) {
            moveOffset = direction.offset
            moveRotation = direction.rotation
            moveScale = direction.squash
        }
        synth.play(frequency: direction.frequency)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                moveOffset = .zero
                moveRotation = 0
                moveScale = CGSize(width: 1, height: 1)
            }
        }
    }
}

#Preview {
    ContentView()
}
