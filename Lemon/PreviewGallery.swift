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
    .runner, .princess
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
