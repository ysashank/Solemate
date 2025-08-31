//
//  Health.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import HealthKit

enum Health {
    static let store = HKHealthStore()
    private static var askedOnce = false
    private static var canShareWorkouts = false

    static func ensureAuthorizationIfNeeded() {
        // Simulator/device without Health → skip silently
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard !askedOnce else { return }
        askedOnce = true

        let toShare: Set = [HKObjectType.workoutType()]
        DispatchQueue.main.async {
            store.requestAuthorization(toShare: toShare, read: []) { success, _ in
                canShareWorkouts = success
            }
        }
    }

    static func storeCompletedWorkout(duration: Int) {
        guard canShareWorkouts else { return }
        let active = max(0, duration)
        let start = Date().addingTimeInterval(TimeInterval(-active))
        let end = Date()
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .flexibility
        
        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        builder.beginCollection(withStart: start) { success, error in
            guard success else { return }
            
            builder.endCollection(withEnd: end) { success, error in
                guard success else { return }
                
                builder.finishWorkout { workout, error in
                    // Silent per product ethos - workout saved or failed silently
                }
            }
        }
    }
}
