import Foundation

enum DurationCalculator {
    static func calculateTotalDuration(for exercises: [Exercise]) -> Int {
        TimelineBuilder.build(from: exercises).reduce(0) { $0 + $1.seconds }
    }

    static func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return s == 0 ? "\(m) minutes" : "\(m) minutes \(s) seconds"
    }
}
