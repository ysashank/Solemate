import Foundation

nonisolated struct TimelineBuilder {
    static func build(from list: [Exercise]) -> [Phase] {
        var phases: [Phase] = []
        for ex in list {
            phases.append(Phase(kind: .prep, exercise: ex, set: 0, rep: nil, side: nil, seconds: Config.prepSeconds))
            let sides: [String?] = ex.perSide
                ? (Config.startOnRightSide ? ["Right", "Left"] : ["Left", "Right"])
                : [nil]
            let reps: [Int?] = if let n = ex.reps { (1...n).map { $0 } } else { [nil] }
            for set in 1...ex.sets {
                for (i, side) in sides.enumerated() {
                    for rep in reps {
                        phases.append(Phase(kind: .work, exercise: ex, set: set, rep: rep, side: side, seconds: ex.holdSeconds))
                    }
                    if set != ex.sets || i != sides.count - 1 {
                        phases.append(Phase(kind: .restSet, exercise: ex, set: set, rep: nil, side: side, seconds: Config.restBetweenSets))
                    }
                }
            }
        }
        return phases
    }
}
