import Foundation
import Observation
import OSLog

@Observable
final class PlayerViewModel {
    private(set) var phases: [Phase] = []
    private(set) var index = 0
    private(set) var remaining = 0
    private(set) var isRunning = false
    private(set) var completion: SessionCompletion?
    private(set) var feedback = Feedback(kind: .warn, id: 0)

    struct Feedback: Equatable {
        let kind: Tick
        let id: Int
    }

    private let logger = Logger(subsystem: "com.sy.Solemate", category: "Player")
    private let exercises: [Exercise]
    private var task: Task<Void, Never>?
    private var startedAt: Date?

    init(exercises: [Exercise] = Ritual.exercises) {
        self.exercises = exercises
        reset()
    }

    var phase: Phase { phases[min(index, phases.count - 1)] }
    var isDone: Bool { completion != nil }

    func reset() {
        phases = TimelineBuilder.build(from: exercises)
        index = 0
        completion = nil
        remaining = phases.first?.seconds ?? 0
        startedAt = nil
    }

    func start() {
        guard !isRunning, !phases.isEmpty else { return }
        SessionAudioService.prepare()
        isRunning = true
        if startedAt == nil {
            startedAt = Date()
            enter()
        }
        schedule()
    }

    func pause() {
        isRunning = false
        task?.cancel()
        task = nil
    }

    func resume() { start() }

    func stop() {
        pause()
        SessionAudioService.release()
        reset()
    }

    private func schedule() {
        task?.cancel()
        task = Task { [weak self] in
            var next = ContinuousClock.now
            while !Task.isCancelled {
                next += .seconds(1)
                try? await Task.sleep(until: next, clock: .continuous)
                guard !Task.isCancelled else { return }
                self?.tick()
            }
        }
    }

    private func tick() {
        guard isRunning else { return }
        remaining -= 1
        guard remaining <= 0 else {
            if remaining <= Config.warnSeconds { cue(.warn) }
            return
        }
        if phase.kind == .work { cue(.end) }
        index += 1
        guard index < phases.count else { return finish() }
        remaining = phases[index].seconds
        enter()
    }

    private func enter() {
        guard phase.kind == .work else { return }
        cue(.start)
    }

    private func cue(_ kind: Tick) {
        SessionAudioService.play(kind)
        if kind != .warn { feedback = Feedback(kind: kind, id: feedback.id + 1) }
    }

    private func finish() {
        pause()
        SessionAudioService.release()
        let start = startedAt ?? Date()
        let end = Date()
        completion = SessionCompletion(
            duration: end.timeIntervalSince(start),
            completedAt: end,
            exerciseCount: exercises.count
        )
        logger.info("Ritual complete: \(self.exercises.count) exercises in \(end.timeIntervalSince(start), format: .fixed(precision: 0))s")
        Health.storeCompletedWorkout(start: start, end: end, exercises: exercises)
    }
}
