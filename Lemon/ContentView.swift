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

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.92)
                .ignoresSafeArea()

            VStack {
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
                }

                Text("Lemon")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(red: 0.55, green: 0.42, blue: 0.05))
                    .padding(.top, 24)
            }
        }
    }
}

#Preview {
    ContentView()
}
