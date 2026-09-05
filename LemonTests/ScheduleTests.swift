import XCTest
@testable import Lemon

/// The schedule maths is where date-gated content fails silently — a wrong
/// boundary only shows up on the one day of the year it matters.
final class ScheduleTests: XCTestCase {

    /// Fixed timezone so these assertions don't depend on where they run.
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int,
                      hour: Int = 12, calendar: Calendar? = nil) -> Date {
        let cal = calendar ?? utc
        return cal.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    // MARK: - Ordinary windows

    func testAnnualWindowIsInclusiveAtBothEnds() {
        let october = Schedule.annual(from: MonthDay(10, 1), through: MonthDay(10, 31))

        XCTAssertTrue(october.contains(date(2026, 10, 1), calendar: utc), "First day should be in.")
        XCTAssertTrue(october.contains(date(2026, 10, 15), calendar: utc))
        XCTAssertTrue(october.contains(date(2026, 10, 31), calendar: utc), "Last day should be in.")

        XCTAssertFalse(october.contains(date(2026, 9, 30), calendar: utc), "Day before should be out.")
        XCTAssertFalse(october.contains(date(2026, 11, 1), calendar: utc), "Day after should be out.")
    }

    func testAnnualWindowRecursEveryYear() {
        let october = Schedule.annual(from: MonthDay(10, 1), through: MonthDay(10, 31))
        for year in [2026, 2027, 2030] {
            XCTAssertTrue(october.contains(date(year, 10, 15), calendar: utc), "Should recur in \(year).")
        }
    }

    // MARK: - The year-wrapping case

    /// A window running Dec 20 -> Jan 6 is the one a naive `start <= today <= end`
    /// check gets wrong, and it only surfaces on Dec 20.
    func testWindowSpanningTheNewYear() {
        let winter = Schedule.annual(from: MonthDay(12, 20), through: MonthDay(1, 6))

        XCTAssertTrue(winter.contains(date(2026, 12, 20), calendar: utc), "Opening day.")
        XCTAssertTrue(winter.contains(date(2026, 12, 31), calendar: utc), "Last day of the year.")
        XCTAssertTrue(winter.contains(date(2027, 1, 1), calendar: utc), "New year's day.")
        XCTAssertTrue(winter.contains(date(2027, 1, 6), calendar: utc), "Closing day.")

        XCTAssertFalse(winter.contains(date(2026, 12, 19), calendar: utc), "Day before opening.")
        XCTAssertFalse(winter.contains(date(2027, 1, 7), calendar: utc), "Day after closing.")
        XCTAssertFalse(winter.contains(date(2026, 7, 1), calendar: utc), "Mid-year is well outside.")
    }

    // MARK: - Single days and one-offs

    func testSingleDayWindow() {
        let halloweenNight = Schedule.day(MonthDay(10, 31))

        XCTAssertTrue(halloweenNight.contains(date(2026, 10, 31, hour: 0), calendar: utc), "Midnight, first moment.")
        XCTAssertTrue(halloweenNight.contains(date(2026, 10, 31, hour: 23), calendar: utc), "Last hour.")
        XCTAssertFalse(halloweenNight.contains(date(2026, 10, 30, hour: 23), calendar: utc))
        XCTAssertFalse(halloweenNight.contains(date(2026, 11, 1, hour: 0), calendar: utc))
    }

    func testOneOffDoesNotRecur() {
        let once = Schedule.oneOff(year: 2026, MonthDay(3, 14))

        XCTAssertTrue(once.contains(date(2026, 3, 14), calendar: utc))
        XCTAssertFalse(once.contains(date(2027, 3, 14), calendar: utc), "A one-off must not come back next year.")
        XCTAssertFalse(once.contains(date(2025, 3, 14), calendar: utc))
    }

    func testLeapDay() {
        let leapDay = Schedule.day(MonthDay(2, 29))

        XCTAssertTrue(leapDay.contains(date(2028, 2, 29), calendar: utc), "2028 is a leap year.")
        // 2027 has no Feb 29 at all, so the window simply never opens.
        XCTAssertFalse(leapDay.contains(date(2027, 2, 28), calendar: utc))
        XCTAssertFalse(leapDay.contains(date(2027, 3, 1), calendar: utc))
    }

    // MARK: - Timezone

    /// The same instant is a different calendar day either side of the date
    /// line, and we deliberately follow the player's local calendar so a
    /// holiday feels local.
    func testWindowFollowsTheSuppliedCalendar() {
        var auckland = Calendar(identifier: .gregorian)
        auckland.timeZone = TimeZone(identifier: "Pacific/Auckland")!
        var losAngeles = Calendar(identifier: .gregorian)
        losAngeles.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        let october = Schedule.annual(from: MonthDay(10, 1), through: MonthDay(10, 31))
        // 2026-09-30 20:00 UTC is already Oct 1 in Auckland, still Sep 30 in LA.
        let instant = date(2026, 9, 30, hour: 20)

        XCTAssertTrue(october.contains(instant, calendar: auckland), "Already October in Auckland.")
        XCTAssertFalse(october.contains(instant, calendar: losAngeles), "Still September in Los Angeles.")
    }

    // MARK: - Clock injection

    func testEventClockCanBeOverriddenAndReset() {
        let pretendOctober = date(2026, 10, 15)
        EventClock.now = { pretendOctober }
        XCTAssertEqual(EventClock.now(), pretendOctober)

        EventClock.reset()
        XCTAssertEqual(EventClock.now().timeIntervalSinceNow, 0, accuracy: 2,
                       "reset() should restore the real clock.")
    }

    // MARK: - Reachability rules (§3 of SEASONAL_STRATEGY.md)

    private func combo(_ availability: Availability) -> ComboDefinition {
        ComboDefinition(
            id: "test", emoji: "🎃", name: "Test",
            sequence: [.direction(.up), .twirl], kind: .lemonPower,
            availability: availability, alwaysRevealed: false
        )
    }

    private let inWindow = DateComponents(year: 2026, month: 10, day: 15)
    private let outOfWindow = DateComponents(year: 2026, month: 6, day: 15)

    func testEventComboIsReachableOnlyInsideItsWindow() {
        let halloween = combo(.event(EventCatalog.halloween))

        XCTAssertTrue(halloween.isReachable(on: utc.date(from: inWindow)!,
                                            isDiscovered: false, calendar: utc),
                      "Should be discoverable during October.")
        XCTAssertFalse(halloween.isReachable(on: utc.date(from: outOfWindow)!,
                                             isDiscovered: false, calendar: utc),
                       "Should be unreachable in June if never found.")
    }

    /// The discovery moment is seasonal; the reward is permanent.
    func testDiscoveredEventComboStaysReachableAfterItsWindowCloses() {
        let halloween = combo(.event(EventCatalog.halloween))

        XCTAssertTrue(halloween.isReachable(on: utc.date(from: outOfWindow)!,
                                            isDiscovered: true, calendar: utc),
                      "Nothing the player already found should be taken away.")
    }

    func testNotReadyIsUnreachableEvenIfSomehowDiscovered() {
        let draft = combo(.notReady)

        XCTAssertFalse(draft.isReachable(on: utc.date(from: inWindow)!,
                                         isDiscovered: true, calendar: utc),
                       "A draft must never be triggerable, discovery flag or not.")
    }

    func testAlwaysIsReachableRegardlessOfDate() {
        let evergreen = combo(.always)

        XCTAssertTrue(evergreen.isReachable(on: utc.date(from: outOfWindow)!,
                                            isDiscovered: false, calendar: utc))
    }

    func testOutOfWindowFlagDrivesTheDimmedRow() {
        let halloween = combo(.event(EventCatalog.halloween))

        XCTAssertFalse(halloween.isOutOfWindow(on: utc.date(from: inWindow)!, calendar: utc))
        XCTAssertTrue(halloween.isOutOfWindow(on: utc.date(from: outOfWindow)!, calendar: utc))
        XCTAssertEqual(halloween.returnsCopy, "Back in October")

        XCTAssertFalse(combo(.always).isOutOfWindow(on: utc.date(from: outOfWindow)!, calendar: utc),
                       "Evergreen combos are never out of window.")
        XCTAssertNil(combo(.always).returnsCopy)
    }

    override func tearDown() {
        EventClock.reset()
        super.tearDown()
    }
}
