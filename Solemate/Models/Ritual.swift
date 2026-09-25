import Foundation

nonisolated enum Ritual {
    static let exercises: [Exercise] = [
        Exercise(
            id: "plantar_arch_stretch",
            title: "Plantar Arch Stretch",
            sets: 2, reps: nil, holdSeconds: 30, perSide: true,
            steps: [
                "Sit and cross ankle over knee",
                "Grab base of toes with same hand",
                "Pull toes back toward shin",
                "Hold stretch"
            ]
        ),
        Exercise(
            id: "toe_spread_curl",
            title: "Toe Spread + Curl",
            sets: 1, reps: 5, holdSeconds: 5, perSide: true,
            steps: [
                "Spread toes wide, hold",
                "Curl toes inward, hold",
                "Relax briefly, repeat"
            ]
        ),
        Exercise(
            id: "toe_drawing",
            title: "Toe Drawing (A–E)",
            sets: 1, reps: nil, holdSeconds: 60, perSide: true,
            steps: [
                "Lift foot off ground",
                "Use big toe to “draw” A–E in the air",
                "Move only the ankle",
                "Keep motion slow and controlled"
            ]
        ),
        Exercise(
            id: "short_foot_drill",
            title: "Short Foot Drill",
            sets: 2, reps: 5, holdSeconds: 5, perSide: false,
            steps: [
                "Stand barefoot",
                "Press ball of foot into ground",
                "Lift arch without curling toes",
                "Hold, then release"
            ]
        ),
        Exercise(
            id: "standing_calf_stretch",
            title: "Standing Calf Stretch",
            sets: 1, reps: nil, holdSeconds: 60, perSide: true,
            steps: [
                "Stand near wall",
                "Step one leg back",
                "Keep heel flat, knee straight",
                "Lean forward to stretch calf"
            ]
        ),
        Exercise(
            id: "arch_massage",
            title: "Arch Massage",
            sets: 1, reps: nil, holdSeconds: 60, perSide: true,
            steps: [
                "Sit with foot on opposite leg",
                "Use thumbs to press into arch",
                "Massage slowly from heel to ball"
            ]
        )
    ]
}
