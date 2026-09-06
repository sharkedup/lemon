import SwiftUI

/// The debug section at the bottom of the help page. Rendered only when
/// `DebugSettings.isAvailable`, so App Store builds never show it — which is
/// why it sits in plain sight rather than behind a secret gesture.
struct DebugPanel: View {
    /// Applied when a form is picked, so the character changes behind the sheet.
    let onPickForm: (Fruit) -> Void
    let onDismiss: () -> Void

    @State private var simulatedDate: Date
    @State private var usesSimulatedDate: Bool
    @State private var showsUnfinished: Bool
    @State private var showingFormPicker = false

    init(onPickForm: @escaping (Fruit) -> Void, onDismiss: @escaping () -> Void) {
        self.onPickForm = onPickForm
        self.onDismiss = onDismiss
        let stored = DebugSettings.simulatedDate
        _simulatedDate = State(initialValue: stored ?? Date())
        _usesSimulatedDate = State(initialValue: stored != nil)
        _showsUnfinished = State(initialValue: DebugSettings.showsUnfinishedCombos)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().padding(.vertical, 4)

            Text("Debug")
                .font(.headline)
            Text("Visible in TestFlight and debug builds only — never in the App Store version.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Toggle("Simulate a date", isOn: $usesSimulatedDate)
                .font(.subheadline)
                .onChange(of: usesSimulatedDate) { _, isOn in
                    DebugSettings.simulatedDate = isOn ? simulatedDate : nil
                }

            if usesSimulatedDate {
                DatePicker("Date", selection: $simulatedDate, displayedComponents: .date)
                    .font(.subheadline)
                    .onChange(of: simulatedDate) { _, newDate in
                        DebugSettings.simulatedDate = newDate
                    }
            }

            Toggle("Show unfinished combos", isOn: $showsUnfinished)
                .font(.subheadline)
                .onChange(of: showsUnfinished) { _, isOn in
                    DebugSettings.showsUnfinishedCombos = isOn
                }

            Button {
                showingFormPicker = true
            } label: {
                Label("Jump to a form…", systemImage: "wand.and.stars")
                    .font(.subheadline.weight(.semibold))
            }

            if DebugSettings.bannerText != nil {
                Button(role: .destructive) {
                    DebugSettings.clearAll()
                    usesSimulatedDate = false
                    showsUnfinished = false
                } label: {
                    Text("Clear all overrides")
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
        .sheet(isPresented: $showingFormPicker) {
            FormPicker { form in
                showingFormPicker = false
                onPickForm(form)
                onDismiss()
            }
        }
    }
}

/// Every form, reachable in one tap — including unfinished ones. Replaces
/// editing `ContentView.init` and rebuilding just to look at a shape.
struct FormPicker: View {
    let onPick: (Fruit) -> Void
    @Environment(\.dismiss) private var dismiss

    private let forms: [Fruit] = [
        .lemon, .clementine, .lime, .lemonadePitcher, .singleSingleDoubleDouble,
        .ruby, .marble, .lemonShark, .runner, .princess, .donut, .apple,
        .greenApple, .coolLemon, .tennisBall, .daisy, .soccerBall,
        .jackOLantern, .ghost, .spider
    ]

    var body: some View {
        NavigationStack {
            List(forms, id: \.name) { form in
                Button {
                    onPick(form)
                } label: {
                    HStack {
                        Text(form.name)
                        Spacer()
                        if isUnfinished(form) {
                            Text("unfinished")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Jump to a form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func isUnfinished(_ form: Fruit) -> Bool {
        ComboCatalog.all.contains {
            if case .notReady = $0.availability, case .transform(let f) = $0.kind {
                return f == form
            }
            return false
        }
    }
}
