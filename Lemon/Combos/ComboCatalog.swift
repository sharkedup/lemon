import Foundation

/// Whether a combo can be reached at all.
///
/// Replaces the old `isEnabled` flag. Phase 2 of `SEASONAL_STRATEGY.md` adds an
/// `.event(Event)` case for date-gated holiday content; until then a combo is
/// either always on, or not finished.
enum Availability {
    /// Evergreen — reachable whenever the app is open.
    case always
    /// Not finished. Never triggerable and never listed, but its art, tune and
    /// `PreviewGallery` entry stay in place. Shelving beats deleting.
    case notReady

    var isCurrentlyAvailable: Bool {
        switch self {
        case .always: return true
        case .notReady: return false
        }
    }
}

/// One secret dance combo: the taps that trigger it, what it does, and how it
/// presents on the help page.
///
/// This is the single source of truth. The help page's arrow strings are
/// **derived** from `sequence` rather than written out a second time, so a hint
/// can no longer drift from the sequence the game actually accepts.
struct ComboDefinition: Identifiable {
    /// Stable key used to persist whether this combo has been discovered.
    let id: String
    let emoji: String
    /// Shown on the help page. Deliberately *not* derived from `Fruit.name` —
    /// "princessDress" lists as "Princess Dress" while the form is "Princess".
    let name: String
    let sequence: [InputAction]
    let kind: ComboKind
    let availability: Availability
    /// Lemon Power is revealed up front to get players started; the rest stay
    /// "???" until discovered.
    let alwaysRevealed: Bool

    /// One entry per press — arrows, plus a closing Twirl prompt for combos
    /// that end on the twirl button — so the help page can reveal them one at
    /// a time instead of spoiling the whole sequence at once.
    var hintSteps: [String] {
        var steps: [String] = []
        var twirled = false
        for action in sequence {
            switch action {
            case .direction(let direction):
                steps.append(direction.hintEmoji)
            case .twirl:
                steps.append(twirled ? "Twirl again!" : "then Twirl!")
                twirled = true
            }
        }
        return steps
    }

    var pressCount: Int { hintSteps.count }
    var fullSequence: String { hintSteps.joined(separator: " ") }
}

extension DanceDirection {
    /// How this direction reads on the help page.
    var hintEmoji: String {
        switch self {
        case .up: return "⬆️"
        case .down: return "⬇️"
        case .left: return "⬅️"
        case .right: return "➡️"
        }
    }
}

/// Every combo in the game, in match order.
///
/// Order matters: matching takes the first candidate whose sequence fits the
/// tail of recent input, so a combo listed earlier shadows any later one whose
/// sequence is a suffix of it. `ComboCatalogTests` guards against that.
enum ComboCatalog {
    static let all: [ComboDefinition] = [
        ComboDefinition(
            id: "lemonPower",
            emoji: "🍋",
            name: "Lemon Power",
            sequence: [.direction(.up), .direction(.up), .direction(.down), .direction(.down), .direction(.right), .direction(.right), .twirl],
            kind: .lemonPower,
            availability: .always,
            alwaysRevealed: true
        ),
        ComboDefinition(
            id: "clementine",
            emoji: "🍊",
            name: "Clementine",
            sequence: [.direction(.up), .direction(.up), .direction(.down), .direction(.down), .direction(.left), .direction(.left), .twirl],
            kind: .transform(.clementine),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "flex",
            emoji: "💪",
            name: "Strong Lemon",
            sequence: [.direction(.down), .direction(.down), .direction(.up), .direction(.up), .direction(.left), .direction(.left), .twirl],
            kind: .flex,
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "lime",
            emoji: "🍋‍🟩",
            name: "Lime",
            sequence: [.direction(.down), .direction(.down), .direction(.up), .direction(.up), .direction(.right), .direction(.right), .twirl],
            kind: .transform(.lime),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "lemonadePitcher",
            emoji: "🥤",
            name: "Lemonade Pitcher",
            sequence: [.direction(.left), .direction(.left), .direction(.right), .direction(.right), .direction(.up), .direction(.up), .twirl],
            kind: .transform(.lemonadePitcher),
            availability: .always,
            alwaysRevealed: false
        ),
        // These four end on a direction rather than a Twirl — they complete
        // the instant the last arrow lands, no Twirl needed.
        //
        // Shelved while their graphics and tunes are reworked (see
        // PreviewGallery.swift) — flip to .always once each one is ready.
        ComboDefinition(
            id: "singleSingleDoubleDouble",
            emoji: "🧔",
            name: "Single Single Double Double",
            sequence: [.direction(.left), .direction(.right), .direction(.left), .direction(.left), .direction(.right), .direction(.left), .direction(.right), .direction(.right)],
            kind: .transform(.singleSingleDoubleDouble),
            availability: .notReady,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "ruby",
            emoji: "🐶",
            name: "Ruby",
            sequence: [.direction(.left), .direction(.up), .direction(.right), .direction(.down), .direction(.left), .direction(.up), .direction(.right), .direction(.down)],
            kind: .transform(.ruby),
            availability: .notReady,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "marble",
            emoji: "🐱",
            name: "Marble",
            sequence: [.direction(.up), .direction(.down), .direction(.up), .direction(.down), .direction(.left), .direction(.right), .direction(.left), .direction(.right)],
            kind: .transform(.marble),
            availability: .notReady,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "lemonShark",
            emoji: "🦈",
            name: "Lemon Shark",
            sequence: [.direction(.down), .direction(.down), .direction(.up), .direction(.up), .direction(.left), .direction(.left), .direction(.right), .direction(.right)],
            kind: .transform(.lemonShark),
            availability: .notReady,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "runner",
            emoji: "🏃",
            name: "Runner",
            sequence: [.direction(.right), .direction(.right), .direction(.up), .direction(.right), .direction(.right), .twirl],
            kind: .transform(.runner),
            availability: .notReady,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "babyLemon",
            emoji: "👶",
            name: "Baby",
            sequence: [.direction(.up), .direction(.up), .direction(.up), .direction(.down), .direction(.down), .direction(.down), .twirl],
            kind: .addBabyLemon,
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "princessDress",
            emoji: "👑",
            name: "Princess Dress",
            sequence: [.direction(.down), .direction(.down), .direction(.up), .direction(.up), .direction(.down), .direction(.up), .twirl],
            kind: .transform(.princess),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "donut",
            emoji: "🍩",
            name: "Donut",
            sequence: [.direction(.right), .direction(.right), .direction(.down), .direction(.down), .direction(.left), .direction(.left), .twirl],
            kind: .transform(.donut),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "apple",
            emoji: "🍎",
            name: "Apple",
            sequence: [.direction(.left), .direction(.left), .direction(.down), .direction(.down), .direction(.right), .direction(.right), .twirl],
            kind: .transform(.apple),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "greenApple",
            emoji: "🍏",
            name: "Green Apple",
            sequence: [.direction(.down), .direction(.down), .direction(.left), .direction(.left), .direction(.up), .direction(.up), .twirl],
            kind: .transform(.greenApple),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "coolLemon",
            emoji: "😎",
            name: "Cool Lemon",
            sequence: [.direction(.up), .direction(.up), .direction(.right), .direction(.right), .direction(.down), .direction(.down), .twirl],
            kind: .transform(.coolLemon),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "tennisBall",
            emoji: "🎾",
            name: "Tennis Ball",
            sequence: [.direction(.right), .direction(.right), .direction(.left), .direction(.left), .direction(.up), .direction(.up), .twirl],
            kind: .transform(.tennisBall),
            availability: .always,
            alwaysRevealed: false
        ),
        ComboDefinition(
            id: "daisy",
            emoji: "🌼",
            name: "Daisy",
            sequence: [.direction(.left), .direction(.right), .direction(.up), .direction(.down), .direction(.left), .direction(.right), .twirl, .twirl],
            kind: .transform(.daisy),
            availability: .always,
            alwaysRevealed: false
        ),
        // Shelved: the panel pattern isn't right yet — revisit later.
        ComboDefinition(
            id: "soccerBall",
            emoji: "⚽",
            name: "Soccer Ball",
            sequence: [.direction(.down), .direction(.up), .direction(.left), .direction(.right), .direction(.down), .direction(.up), .twirl],
            kind: .transform(.soccerBall),
            availability: .notReady,
            alwaysRevealed: false
        )
    ]

    /// What `recordInput` matches against, and what the help page lists.
    static var available: [ComboDefinition] {
        all.filter(\.availability.isCurrentlyAvailable)
    }
}
