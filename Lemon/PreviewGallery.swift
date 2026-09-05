import SwiftUI

// MARK: - Preview-only sandbox
//
// Nothing in this file ships in the app or is referenced by it — it exists so
// the actual shapes/colors/decorations used in ContentView.swift can be seen
// and tweaked live in Xcode's Canvas (Editor > Canvas, or ⌥⌘↩) instead of
// rebuilding and walking through combos in the Simulator every time.
//
// Edit any decoration view in ContentView.swift (dogEars, catFacePatch,
// sharkFin, LemonShape's path, colors in Fruit.bodyColors, etc.) with Canvas
// open and pinned to one of the previews below — it updates in a second or
// two, live, with no build.

private let allForms: [Fruit] = [
    .lemon, .clementine, .lime, .lemonadePitcher,
    .singleSingleDoubleDouble, .ruby, .marble, .lemonShark,
    .runner, .princess, .donut, .apple, .greenApple, .coolLemon, .tennisBall, .daisy
]

/// A small helper so a `Fruit` case can be dropped into a `.frame(...)`-sized
/// cell without dragging in the rest of the app's scene (background, dpad,
/// Twirl button, help sheet). `ContentView(...).lemonCharacter` is the same
/// character view the real app renders, just lifted out on its own.
private struct FormCell: View {
    let fruit: Fruit
    var scale: CGFloat = 0.55

    var body: some View {
        VStack(spacing: 6) {
            ContentView(previewForm: fruit, previewAwake: true)
                .lemonCharacter
                .scaleEffect(scale)
                .frame(width: 150, height: 140)
                .clipped()
            Text(fruit.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.55, green: 0.42, blue: 0.05))
                .multilineTextAlignment(.center)
        }
        .frame(width: 150)
    }
}

/// Every form at a glance, for comparing color/silhouette choices side by side.
#Preview("All Forms") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 20) {
            ForEach(Array(allForms.enumerated()), id: \.offset) { _, fruit in
                FormCell(fruit: fruit)
            }
        }
        .padding()
    }
    .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

/// Large single-form views for detailed work — duplicate this block with a
/// different `previewForm:` for whichever form you're actively tweaking.
#Preview("Ruby — Detail") {
    ContentView(previewForm: .ruby, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Marble — Detail") {
    ContentView(previewForm: .marble, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Lemon Shark — Detail") {
    ContentView(previewForm: .lemonShark, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Single Single Double Double — Detail") {
    ContentView(previewForm: .singleSingleDoubleDouble, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Princess — Detail") {
    ContentView(previewForm: .princess, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Runner — Detail") {
    ContentView(previewForm: .runner, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Donut — Detail") {
    ContentView(previewForm: .donut, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Apple — Detail") {
    ContentView(previewForm: .apple, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Green Apple — Detail") {
    ContentView(previewForm: .greenApple, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Cool Lemon — Detail") {
    ContentView(previewForm: .coolLemon, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Tennis Ball — Detail") {
    ContentView(previewForm: .tennisBall, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

#Preview("Daisy — Detail") {
    ContentView(previewForm: .daisy, previewAwake: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

/// The main lemon plus its Baby Lemon companion, since that's a separate
/// toggle rather than a `Fruit` case.
#Preview("Baby Lemon Companion") {
    ContentView(previewForm: .lemon, previewAwake: true, previewBabyLemon: true)
        .lemonCharacter
        .frame(width: 420, height: 420)
        .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

/// Asleep vs. awake, side by side — useful since eyes/mouth change shape.
#Preview("Asleep vs Awake") {
    HStack(spacing: 20) {
        VStack {
            ContentView(previewForm: .lemon, previewAwake: false)
                .lemonCharacter
                .frame(width: 300, height: 300)
            Text("Asleep")
        }
        VStack {
            ContentView(previewForm: .lemon, previewAwake: true)
                .lemonCharacter
                .frame(width: 300, height: 300)
            Text("Awake")
        }
    }
    .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

// MARK: - Coordinate grids
//
// Two different coordinate systems show up in ContentView.swift:
//
// 1. Inside a custom `Shape`'s `path(in rect:)` — points are fractions of
//    the shape's own rect, 0.0...1.0 on each axis. `FractionGrid` below
//    overlays that grid (red) on top of a shape so a call like
//    `p(0.74, 0.93)` can be read straight off the image.
//
// 2. `.offset(x:y:)` on a decoration (ears, patches, fins, the tiara...) —
//    plain points, relative to the character's own center at (0, 0).
//    `PointGrid` below overlays that grid (blue) so an offset like
//    `x: -112, y: -66` can be read the same way.

/// Red grid, 0.0–1.0 on each axis, for `Shape.path(in:)` fraction coordinates.
private struct FractionGrid: View {
    var divisions: Int = 10

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                ForEach(0...divisions, id: \.self) { i in
                    let fraction = CGFloat(i) / CGFloat(divisions)
                    let isCenter = i == divisions / 2

                    Path { path in
                        path.move(to: CGPoint(x: w * fraction, y: 0))
                        path.addLine(to: CGPoint(x: w * fraction, y: h))
                    }
                    .stroke(Color.red.opacity(isCenter ? 0.4 : 0.15), lineWidth: isCenter ? 1.2 : 0.5)

                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h * fraction))
                        path.addLine(to: CGPoint(x: w, y: h * fraction))
                    }
                    .stroke(Color.red.opacity(isCenter ? 0.4 : 0.15), lineWidth: isCenter ? 1.2 : 0.5)
                }

                ForEach(0...divisions, id: \.self) { i in
                    let fraction = CGFloat(i) / CGFloat(divisions)
                    Text(String(format: "%.1f", fraction))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color.red.opacity(0.85))
                        .position(x: w * fraction, y: 8)
                    Text(String(format: "%.1f", fraction))
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color.red.opacity(0.85))
                        .position(x: 12, y: h * fraction)
                }
            }
        }
    }
}

/// Blue grid, centered on (0, 0), for `.offset(x:y:)` point coordinates.
/// Lines every `step` points out to `extent` in each direction.
private struct PointGrid: View {
    var extent: CGFloat = 160
    var step: CGFloat = 20

    private var steps: Int { Int(extent / step) }

    var body: some View {
        ZStack {
            ForEach(-steps...steps, id: \.self) { i in
                let value = CGFloat(i) * step
                let isCenter = i == 0

                Path { path in
                    path.move(to: CGPoint(x: value + extent, y: 0))
                    path.addLine(to: CGPoint(x: value + extent, y: extent * 2))
                }
                .stroke(Color.blue.opacity(isCenter ? 0.5 : 0.15), lineWidth: isCenter ? 1.2 : 0.5)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: value + extent))
                    path.addLine(to: CGPoint(x: extent * 2, y: value + extent))
                }
                .stroke(Color.blue.opacity(isCenter ? 0.5 : 0.15), lineWidth: isCenter ? 1.2 : 0.5)
            }

            ForEach(Array(stride(from: -steps, through: steps, by: 2)), id: \.self) { i in
                let value = CGFloat(i) * step
                Text("\(Int(value))")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(Color.blue.opacity(0.85))
                    .position(x: value + extent, y: 6)
                Text("\(Int(value))")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundStyle(Color.blue.opacity(0.85))
                    .position(x: 6, y: value + extent)
            }
        }
        .frame(width: extent * 2, height: extent * 2)
    }
}

/// Red 0–1 grid over `LemonShape` alone, for editing its `path(in:)`.
#Preview("Grid — Lemon Shape") {
    ZStack {
        LemonShape()
            .fill(Color.yellow.opacity(0.3))
            .overlay(LemonShape().stroke(Color(red: 0.75, green: 0.58, blue: 0.05), lineWidth: 2))
        FractionGrid()
    }
    .frame(width: 260, height: 220)
    .padding(40)
    .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

/// Red 0–1 grid over `PitcherShape` alone, for editing its `path(in:)`.
#Preview("Grid — Pitcher Shape") {
    ZStack {
        PitcherShape()
            .fill(Color.yellow.opacity(0.3))
            .overlay(PitcherShape().stroke(Color(red: 0.75, green: 0.58, blue: 0.05), lineWidth: 2))
        FractionGrid()
    }
    .frame(width: 260, height: 220)
    .padding(40)
    .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

/// Blue point grid over Ruby, for reading/editing `dogEars` and
/// `dogFacePatch`'s `.offset(x:y:)` values.
#Preview("Grid — Ruby Offsets") {
    ZStack {
        ContentView(previewForm: .ruby, previewAwake: true).lemonCharacter
        PointGrid(extent: 160, step: 20)
    }
    .frame(width: 320, height: 320)
    .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}

/// Blue point grid over Marble, for reading/editing `catEars`, `catFacePatch`
/// and `whiskers`' `.offset(x:y:)` values.
#Preview("Grid — Marble Offsets") {
    ZStack {
        ContentView(previewForm: .marble, previewAwake: true).lemonCharacter
        PointGrid(extent: 160, step: 20)
    }
    .frame(width: 320, height: 320)
    .background(Color(red: 0.98, green: 0.98, blue: 0.92))
}
