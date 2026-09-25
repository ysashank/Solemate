import Foundation

nonisolated struct Exercise: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let sets: Int
    let reps: Int?
    let holdSeconds: Int
    let perSide: Bool
    let steps: [String]

    var subtitle: String {
        var parts = ["\(sets) set\(sets == 1 ? "" : "s")\(perSide ? " per side" : "")"]
        if let reps { parts.append("\(reps) reps") }
        parts.append("\(holdSeconds)s")
        return parts.joined(separator: " • ")
    }
}

nonisolated enum PhaseKind { case prep, work, restSet }

nonisolated struct Phase {
    let kind: PhaseKind
    let exercise: Exercise
    let set: Int
    let rep: Int?
    let side: String?
    let seconds: Int
}

struct SessionCompletion {
    let duration: TimeInterval
    let completedAt: Date
    let exerciseCount: Int
}
