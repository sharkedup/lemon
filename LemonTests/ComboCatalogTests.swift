import XCTest
@testable import Lemon

/// Guards the invariants that fail *silently* — where the app still builds,
/// still looks right in the simulator, and is quietly broken for players.
/// Visual regressions are deliberately out of scope; those you catch by eye.
final class ComboCatalogTests: XCTestCase {

    private let combos = ContentView.combos
    private let hints = HelpView.hints

    // MARK: - Catalog integrity

    func testComboIDsAreUnique() {
        let ids = combos.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count,
                       "Duplicate combo id — discovery state is keyed by id, so duplicates share progress.")
    }

    func testEveryComboHasAMatchingHintAndViceVersa() {
        let comboIDs = Set(combos.map(\.id))
        let hintIDs = Set(hints.map(\.id))

        XCTAssertEqual(comboIDs.subtracting(hintIDs), [],
                       "Combo(s) with no hint — unreachable for players, who'd never learn the sequence.")
        XCTAssertEqual(hintIDs.subtracting(comboIDs), [],
                       "Hint(s) with no combo — the help page would teach a sequence that does nothing.")
    }

    func testEnabledFlagsAgreeBetweenCombosAndHints() {
        let hintsByID = Dictionary(uniqueKeysWithValues: hints.map { ($0.id, $0) })

        for combo in combos {
            guard let hint = hintsByID[combo.id] else { continue }  // covered above
            XCTAssertEqual(combo.isEnabled, hint.isEnabled,
                           "'\(combo.id)' is enabled in one catalog but not the other — it would be listed but untriggerable, or triggerable but invisible.")
        }
    }

    // MARK: - Hint text matches the real sequence

    /// Mirrors how the hint strings are written by hand today. Once the
    /// catalogs are unified this becomes production code and this test
    /// becomes unnecessary.
    private func expectedSteps(for sequence: [InputAction]) -> [String] {
        var steps: [String] = []
        var seenTwirl = false
        for action in sequence {
            switch action {
            case .direction(.up):    steps.append("⬆️")
            case .direction(.down):  steps.append("⬇️")
            case .direction(.left):  steps.append("⬅️")
            case .direction(.right): steps.append("➡️")
            case .twirl:
                steps.append(seenTwirl ? "Twirl again!" : "then Twirl!")
                seenTwirl = true
            }
        }
        return steps
    }

    func testHintStepsMatchTheirComboSequences() {
        let hintsByID = Dictionary(uniqueKeysWithValues: hints.map { ($0.id, $0) })

        for combo in combos {
            guard let hint = hintsByID[combo.id] else { continue }
            XCTAssertEqual(hint.steps, expectedSteps(for: combo.sequence),
                           "'\(combo.id)' hint does not match its combo — the help page is teaching players a sequence that won't work.")
        }
    }

    // MARK: - Reachability

    /// Matching compares against the *tail* of recent input, taking the first
    /// candidate that fits. So if one enabled combo's sequence is a suffix of
    /// another's, whichever is declared first always wins and the other can
    /// never fire.
    func testNoEnabledComboIsShadowedBySuffixCollision() {
        let enabled = combos.filter(\.isEnabled)

        for (i, combo) in enabled.enumerated() {
            for (j, other) in enabled.enumerated() where i != j {
                guard combo.sequence.count >= other.sequence.count else { continue }
                let tail = Array(combo.sequence.suffix(other.sequence.count))
                XCTAssertNotEqual(tail, other.sequence,
                                  "'\(other.id)' is a suffix of '\(combo.id)' — one of them can never be triggered.")
            }
        }
    }

    // MARK: - Matching behaviour

    func testMatchingReturnsTheExpectedCombo() {
        let cases: [(id: String, sequence: [InputAction])] = ContentView.activeCombos.map {
            ($0.id, $0.sequence)
        }

        for expected in cases {
            let match = ContentView.matchingCombo(history: expected.sequence, in: ContentView.activeCombos)
            XCTAssertEqual(match?.id, expected.id,
                           "Entering '\(expected.id)'s own sequence did not trigger it.")
        }
    }

    func testPartialSequenceMatchesNothing() {
        guard let daisy = ContentView.activeCombos.first(where: { $0.id == "daisy" }) else {
            return XCTFail("daisy combo missing")
        }
        let partial = Array(daisy.sequence.dropLast())
        XCTAssertNil(ContentView.matchingCombo(history: partial, in: ContentView.activeCombos),
                     "An incomplete sequence fired a combo.")
    }

    func testDisabledCombosAreNotReachable() {
        for combo in combos where !combo.isEnabled {
            let match = ContentView.matchingCombo(history: combo.sequence, in: ContentView.activeCombos)
            XCTAssertNotEqual(match?.id, combo.id,
                              "Shelved combo '\(combo.id)' can still be triggered.")
        }
    }
}
