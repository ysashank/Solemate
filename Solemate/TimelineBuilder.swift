//
//  TimelineBuilder.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import Foundation

struct TimelineBuilder {
    static func build(from list: [Exercise]) -> [Phase] {
        var phases: [Phase] = []

        for ex in list {
            // Prep before exercise
            phases.append(
                Phase(kind: .prep, exercise: ex, set: 0, rep: nil, side: nil,
                      seconds: Config.prepSeconds, nextTitle: ex.title)
            )

            if ex.perSide {
                // For per-side exercises: do each set for both sides
                for set in 1...ex.sets {
                    let sides = Config.startOnRightSide ? ["Right", "Left"] : ["Left", "Right"]
                    
                    for (sideIndex, side) in sides.enumerated() {
                        // Work phase
                        if let reps = ex.reps {
                            for r in 1...reps {
                                phases.append(
                                    Phase(kind: .work, exercise: ex, set: set, rep: r, side: side,
                                          seconds: ex.holdSeconds, nextTitle: nil)
                                )
                            }
                        } else {
                            phases.append(
                                Phase(kind: .work, exercise: ex, set: set, rep: nil, side: side,
                                      seconds: ex.holdSeconds, nextTitle: nil)
                            )
                        }
                        
                        // Rest between sides or sets (but not after the last one)
                        let isLastSide = (sideIndex == sides.count - 1)
                        let isLastSet = (set == ex.sets)
                        
                        if !isLastSide || !isLastSet {
                            let nextTitle: String
                            if !isLastSide {
                                // Next is the other side of the same set - show current exercise title
                                nextTitle = ex.title
                            } else {
                                // Next is the first side of the next set - show current exercise title
                                nextTitle = ex.title
                            }
                            
                            phases.append(
                                Phase(kind: .restSet, exercise: ex, set: set, rep: nil, side: side,
                                      seconds: Config.restBetweenSets, nextTitle: nextTitle)
                            )
                        }
                    }
                }
            } else {
                // For regular exercises: just do the sets normally
                for set in 1...ex.sets {
                    // Work phase
                    if let reps = ex.reps {
                        for r in 1...reps {
                            phases.append(
                                Phase(kind: .work, exercise: ex, set: set, rep: r, side: nil,
                                      seconds: ex.holdSeconds, nextTitle: nil)
                            )
                        }
                    } else {
                        phases.append(
                            Phase(kind: .work, exercise: ex, set: set, rep: nil, side: nil,
                                  seconds: ex.holdSeconds, nextTitle: nil)
                        )
                    }
                    
                    // Rest between sets (but not after the last set)
                    if set != ex.sets {
                        // Rest between sets of same exercise - show current exercise title
                        let nextTitle = ex.title
                        phases.append(
                            Phase(kind: .restSet, exercise: ex, set: set, rep: nil, side: nil,
                                  seconds: Config.restBetweenSets, nextTitle: nextTitle)
                        )
                    }
                }
            }
        }

        if let last = list.last {
            phases.append(Phase(kind: .done, exercise: last, set: 0, rep: nil, side: nil, seconds: 0, nextTitle: nil))
        }
        return phases
    }
}
