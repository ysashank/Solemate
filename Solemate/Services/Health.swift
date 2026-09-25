import HealthKit
import OSLog

enum Health {
    nonisolated private static let logger = Logger(subsystem: "com.sy.Solemate", category: "Health")
    private static let store = HKHealthStore()
    private static var askedOnce = false

    static func ensureAuthorizationIfNeeded() {
        guard HKHealthStore.isHealthDataAvailable(), !askedOnce else { return }
        askedOnce = true
        Task {
            do {
                try await store.requestAuthorization(toShare: [HKObjectType.workoutType()], read: [])
            } catch {
                logger.error("Authorization failed: \(error.localizedDescription)")
            }
        }
    }

    nonisolated static func storeCompletedWorkout(start: Date, end: Date, exercises: [Exercise]) {
        let store = HKHealthStore()
        guard HKHealthStore.isHealthDataAvailable(),
              store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized else {
            logger.info("Skipping workout write: not authorized")
            return
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .flexibility
        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        Task {
            do {
                try await builder.beginCollection(at: start)
                try await builder.addMetadata(metadata(for: exercises))
                try await builder.endCollection(at: end)
                try await builder.finishWorkout()
                logger.info("Logged \(exercises.count) exercises to Health")
            } catch {
                logger.error("Workout write failed: \(error.localizedDescription)")
            }
        }
    }

    nonisolated private static func metadata(for exercises: [Exercise]) -> [String: Any] {
        [
            HKMetadataKeyWorkoutBrandName: "Solemate",
            "sessionSource": "daily_ritual",
            "exerciseCount": exercises.count,
            "exercises": exercises.map(\.id).joined(separator: ","),
            "totalNominalSeconds": DurationCalculator.calculateTotalDuration(for: exercises),
        ]
    }
}
