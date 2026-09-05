import Foundation

/// Overrides for previewing time-gated and unfinished content, available in
/// debug builds and TestFlight but never in an App Store build.
///
/// Date-gated content is otherwise impossible to review before its date, and
/// TestFlight ships Release builds — so neither an environment variable nor
/// `#if DEBUG` alone reaches the people testing it.
enum DebugSettings {

    /// A TestFlight install's receipt is named `sandboxReceipt` rather than
    /// `receipt`. This is a heuristic rather than a guarantee, but the worst
    /// case if it ever misfired is somebody seeing Halloween early.
    static let isAvailable: Bool = {
        #if DEBUG
        return true
        #else
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        #endif
    }()

    private static let simulatedDateKey = "debugSimulatedDate"
    private static let showsUnfinishedKey = "debugShowsUnfinishedCombos"

    /// Pretend it is this date. `nil` means use the real clock.
    static var simulatedDate: Date? {
        get {
            guard isAvailable else { return nil }
            let stamp = UserDefaults.standard.double(forKey: simulatedDateKey)
            return stamp == 0 ? nil : Date(timeIntervalSince1970: stamp)
        }
        set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970 ?? 0, forKey: simulatedDateKey)
            applyToClock()
        }
    }

    /// Fold `.notReady` combos into the matchable set.
    ///
    /// Off by default on purpose: TestFlight should match production until
    /// somebody deliberately changes it, or testers report problems with forms
    /// that were already shelved and their attention goes to the wrong place.
    static var showsUnfinishedCombos: Bool {
        get { isAvailable && UserDefaults.standard.bool(forKey: showsUnfinishedKey) }
        set { UserDefaults.standard.set(newValue, forKey: showsUnfinishedKey) }
    }

    /// Points `EventClock` at the stored override. Call once at launch.
    static func applyToClock() {
        if let simulated = simulatedDate {
            EventClock.now = { simulated }
        } else {
            EventClock.reset()
        }
    }

    static func clearAll() {
        simulatedDate = nil
        showsUnfinishedCombos = false
    }

    /// Shown on screen the whole time anything is overridden. Without it,
    /// somebody flips a switch, forgets, and files a confusing bug weeks later.
    static var bannerText: String? {
        guard isAvailable else { return nil }

        var parts: [String] = []
        if let simulated = simulatedDate {
            parts.append("simulated date \(dateFormatter.string(from: simulated))")
        }
        if showsUnfinishedCombos {
            parts.append("unfinished combos shown")
        }
        guard !parts.isEmpty else { return nil }
        return "Debug · " + parts.joined(separator: " · ")
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
}
