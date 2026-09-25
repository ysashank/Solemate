import HealthKit

@MainActor
enum Health {
    static let store = HKHealthStore()
    private static var askedOnce = false

    static func ensureAuthorizationIfNeeded() {
        guard HKHealthStore.isHealthDataAvailable(), !askedOnce else { return }
        askedOnce = true
        DispatchQueue.main.async {
            store.requestAuthorization(toShare: [HKObjectType.workoutType()], read: []) { _, _ in }
        }
    }

    nonisolated static func storeCompletedWorkout(start: Date, end: Date) {
        let store = HKHealthStore()
        guard HKHealthStore.isHealthDataAvailable(),
              store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .flexibility
        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        builder.beginCollection(withStart: start) { success, error in
            guard success else { return log(error) }
            builder.endCollection(withEnd: end) { success, error in
                guard success else { return log(error) }
                builder.finishWorkout { _, error in log(error) }
            }
        }
    }

    nonisolated private static func log(_ error: (any Error)?) {
        if let error { print("Health: \(error)") }
    }
}
