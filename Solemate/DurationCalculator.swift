//
//  DurationCalculator.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import Foundation

enum DurationCalculator {
    static func calculateTotalDuration(for exercises: [Exercise]) -> Int {
        var totalSeconds = 0
        
        for ex in exercises {
            // Prep before each exercise
            totalSeconds += Config.prepSeconds
            
            if ex.perSide {
                // For per-side exercises: do each set for both sides
                for set in 1...ex.sets {
                    let sidesCount = 2 // Right and Left
                    
                    for sideIndex in 0..<sidesCount {
                        // Work phase
                        if let reps = ex.reps {
                            totalSeconds += ex.holdSeconds * reps
                        } else {
                            totalSeconds += ex.holdSeconds
                        }
                        
                        // Rest between sides or sets (but not after the last one)
                        let isLastSide = (sideIndex == sidesCount - 1)
                        let isLastSet = (set == ex.sets)
                        
                        if !isLastSide || !isLastSet {
                            totalSeconds += Config.restBetweenSets
                        }
                    }
                }
            } else {
                // For regular exercises: just do the sets normally
                for set in 1...ex.sets {
                    // Work phase
                    if let reps = ex.reps {
                        totalSeconds += ex.holdSeconds * reps
                    } else {
                        totalSeconds += ex.holdSeconds
                    }
                    
                    // Rest between sets (but not after the last set)
                    if set != ex.sets {
                        totalSeconds += Config.restBetweenSets
                    }
                }
            }
        }
        
        return totalSeconds
    }
    
    static func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if remainingSeconds == 0 {
            return "\(minutes) minutes"
        } else {
            return "\(minutes) minutes \(remainingSeconds) seconds"
        }
    }
    
    static func formatDurationApproximate(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        // Round to nearest minute for "about" display
        let roundedMinutes = remainingSeconds >= 30 ? minutes + 1 : minutes
        return "About \(roundedMinutes) minutes"
    }
}
