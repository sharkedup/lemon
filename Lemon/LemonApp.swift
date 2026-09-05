import SwiftUI

@main
struct LemonApp: App {
    init() {
        // A simulated date set in the debug panel has to survive relaunch.
        DebugSettings.applyToClock()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
