import XCTest
@testable import Lemon

/// Guards the invariants that fail *silently* — where the app still builds,
/// still looks right in the simulator, and is quietly broken for players.
/// Visual regressions are deliberately out of scope; those you catch by eye.
final class ComboCatalogTests: XCTestCase {

    private let combos = ComboCatalog.all

    // MARK: - Catalog integrity

    func testComboIDsAreUnique() {
        let ids = combos.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count,
                       "Duplicate combo id — discovery state is keyed by id, so duplicates would share progress.")
    }

    func testEveryComboHasNameAndEmoji() {
        for combo in combos {
            XCTAssertFalse(combo.name.isEmpty, "'\(combo.id)' has no name for the help page.")
            XCTAssertFalse(combo.emoji.isEmpty, "'\(combo.id)' has no emoji for the help page.")
        }
    }

    // MARK: - Derived hints

    /// Snapshot of the hand-written hint strings as they shipped before the
    /// catalogs were unified. Derived steps must reproduce these exactly.
    private let legacyHintSteps: [String: [String]] = [
        "lemonPower": ["⬆️", "⬆️", "⬇️", "⬇️", "➡️", "➡️", "then Twirl!"],
        "clementine": ["⬆️", "⬆️", "⬇️", "⬇️", "⬅️", "⬅️", "then Twirl!"],
        "flex": ["⬇️", "⬇️", "⬆️", "⬆️", "⬅️", "⬅️", "then Twirl!"],
        "lime": ["⬇️", "⬇️", "⬆️", "⬆️", "➡️", "➡️", "then Twirl!"],
        "lemonadePitcher": ["⬅️", "⬅️", "➡️", "➡️", "⬆️", "⬆️", "then Twirl!"],
        "singleSingleDoubleDouble": ["⬅️", "➡️", "⬅️", "⬅️", "➡️", "⬅️", "➡️", "➡️"],
        "ruby": ["⬅️", "⬆️", "➡️", "⬇️", "⬅️", "⬆️", "➡️", "⬇️"],
        "marble": ["⬆️", "⬇️", "⬆️", "⬇️", "⬅️", "➡️", "⬅️", "➡️"],
        "lemonShark": ["⬇️", "⬇️", "⬆️", "⬆️", "⬅️", "⬅️", "➡️", "➡️"],
        "runner": ["➡️", "➡️", "⬆️", "➡️", "➡️", "then Twirl!"],
        "babyLemon": ["⬆️", "⬆️", "⬆️", "⬇️", "⬇️", "⬇️", "then Twirl!"],
        "princessDress": ["⬇️", "⬇️", "⬆️", "⬆️", "⬇️", "⬆️", "then Twirl!"],
        "donut": ["➡️", "➡️", "⬇️", "⬇️", "⬅️", "⬅️", "then Twirl!"],
        "apple": ["⬅️", "⬅️", "⬇️", "⬇️", "➡️", "➡️", "then Twirl!"],
        "greenApple": ["⬇️", "⬇️", "⬅️", "⬅️", "⬆️", "⬆️", "then Twirl!"],
        "coolLemon": ["⬆️", "⬆️", "➡️", "➡️", "⬇️", "⬇️", "then Twirl!"],
        "tennisBall": ["➡️", "➡️", "⬅️", "⬅️", "⬆️", "⬆️", "then Twirl!"],
        "daisy": ["⬅️", "➡️", "⬆️", "⬇️", "⬅️", "➡️", "then Twirl!", "Twirl again!"],
        "soccerBall": ["⬇️", "⬆️", "⬅️", "➡️", "⬇️", "⬆️", "then Twirl!"],
    ]

    /// The catalogs used to be written out twice, and the hint strings were
    /// retyped by hand. They are derived now — this proves the derivation
    /// reproduces what actually shipped, byte for byte.
    func testDerivedHintStepsMatchWhatShipped() {
        XCTAssertEqual(Set(combos.map(\.id)), Set(legacyHintSteps.keys),
                       "Catalog no longer lines up with the shipped snapshot.")

        for combo in combos {
            guard let expected = legacyHintSteps[combo.id] else { continue }
            XCTAssertEqual(combo.hintSteps, expected,
                           "'\(combo.id)' derives different hint text than it shipped with.")
        }
    }

    func testHintStepCountMatchesSequenceLength() {
        for combo in combos {
            XCTAssertEqual(combo.pressCount, combo.sequence.count,
                           "'\(combo.id)' hint has a different number of presses than its sequence.")
        }
    }

    // MARK: - Reachability

    /// Matching compares against the *tail* of recent input, taking the first
    /// candidate that fits. So if one available combo's sequence is a suffix of
    /// another's, whichever is declared first always wins and the other can
    /// never fire.
    func testNoAvailableComboIsShadowedBySuffixCollision() {
        let available = ComboCatalog.available

        for (i, combo) in available.enumerated() {
            for (j, other) in available.enumerated() where i != j {
                guard combo.sequence.count >= other.sequence.count else { continue }
                let tail = Array(combo.sequence.suffix(other.sequence.count))
                XCTAssertNotEqual(tail, other.sequence,
                                  "'\(other.id)' is a suffix of '\(combo.id)' — one of them can never be triggered.")
            }
        }
    }

    // MARK: - Matching behaviour

    func testMatchingReturnsTheExpectedCombo() {
        for combo in ComboCatalog.available {
            let match = ContentView.matchingCombo(history: combo.sequence, in: ComboCatalog.available)
            XCTAssertEqual(match?.id, combo.id,
                           "Entering '\(combo.id)'s own sequence did not trigger it.")
        }
    }

    func testPartialSequenceMatchesNothing() {
        guard let daisy = ComboCatalog.available.first(where: { $0.id == "daisy" }) else {
            return XCTFail("daisy combo missing")
        }
        let partial = Array(daisy.sequence.dropLast())
        XCTAssertNil(ContentView.matchingCombo(history: partial, in: ComboCatalog.available),
                     "An incomplete sequence fired a combo.")
    }

    func testNotReadyCombosAreNotReachable() {
        for combo in combos where !combo.availability.isCurrentlyAvailable {
            let match = ContentView.matchingCombo(history: combo.sequence, in: ComboCatalog.available)
            XCTAssertNotEqual(match?.id, combo.id,
                              "Shelved combo '\(combo.id)' can still be triggered.")
        }
    }
}
