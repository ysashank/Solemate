import Foundation

nonisolated enum Config {
    static let prepSeconds = 5
    static let restBetweenSets = 5
    static let startOnRightSide = true
    // Terminal countdown. Breathwork cues every 5th remaining second instead; the alarm is the
    // one deliberate iOS departure, and HoldTimer uses the same window.
    static let warnSeconds = 5
}
