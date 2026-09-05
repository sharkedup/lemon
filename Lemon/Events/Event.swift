import Foundation

/// A month and day with no year attached — the shape almost every holiday
/// window has.
struct MonthDay: Equatable {
    let month: Int
    let day: Int

    init(_ month: Int, _ day: Int) {
        self.month = month
        self.day = day
    }

    /// A stable ordering within a year. Not a real date — just enough to
    /// compare two points, so Feb 29 sits between Feb 28 and Mar 1.
    var ordinal: Int { month * 100 + day }
}

/// When an event is on. Purely a time predicate — it knows nothing about the
/// content it gates, which is what lets a one-day surprise and a month-long
/// holiday pack be the same type.
enum Schedule {
    /// Recurs every year between two points, inclusive at both ends. Wraps the
    /// year boundary when `from` falls later in the year than `through`.
    case annual(from: MonthDay, through: MonthDay)

    /// One specific date in one specific year. Never repeats.
    case oneOff(year: Int, MonthDay)

    /// A single day, every year.
    static func day(_ monthDay: MonthDay) -> Schedule {
        .annual(from: monthDay, through: monthDay)
    }

    /// Whether `date` falls inside this schedule.
    ///
    /// The calendar is a parameter rather than read from the environment so
    /// this stays a pure function — tests pass a fixed timezone, and the app
    /// passes the player's own calendar so holidays feel local.
    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else {
            return false
        }
        let today = MonthDay(month, day).ordinal

        switch self {
        case .annual(let from, let through):
            if from.ordinal <= through.ordinal {
                return today >= from.ordinal && today <= through.ordinal
            }
            // Wraps the new year — "late in the old year, or early in the new".
            return today >= from.ordinal || today <= through.ordinal

        case .oneOff(let onlyYear, let monthDay):
            return year == onlyYear && today == monthDay.ordinal
        }
    }
}

/// A named, themed bundle of content and the schedule that switches it on.
struct Event {
    let id: String
    let name: String
    let schedule: Schedule
    /// Shown on the help page for a discovered combo whose window has closed.
    /// Per-event because "Back in October" is wrong for a one-off.
    let returnsCopy: String

    func isActive(on date: Date, calendar: Calendar = .current) -> Bool {
        schedule.contains(date, calendar: calendar)
    }
}

/// The app's notion of "now".
///
/// Injectable so tests, Xcode previews and the TestFlight debug panel can
/// pretend it is October without touching the system clock.
enum EventClock {
    static var now: () -> Date = { Date() }

    /// Restores the real clock. Tests should call this in `tearDown`.
    static func reset() {
        now = { Date() }
    }
}

/// Every event in the game.
///
/// Swift data rather than JSON or remote config: both of those still require a
/// build to change, so they add failure modes without buying anything. See
/// `SEASONAL_STRATEGY.md` §4.
enum EventCatalog {
    /// No combos are assigned to this yet — the Halloween pack is Phase 3
    /// content. Defined now so the schedule plumbing has something real to
    /// exercise.
    static let halloween = Event(
        id: "halloween",
        name: "Halloween",
        schedule: .annual(from: MonthDay(10, 1), through: MonthDay(10, 31)),
        returnsCopy: "Back in October"
    )

    static let all: [Event] = [halloween]
}
