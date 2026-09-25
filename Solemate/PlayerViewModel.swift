import Foundation
import Observation

@MainActor
@Observable
final class PlayerViewModel {
    private(set) var phases: [Phase] = []
    private(set) var index: Int = 0
    private(set) var remaining: Int = 0
    private(set) var isRunning: Bool = false
    private(set) var isDone: Bool = false

    private let exercises: [Exercise]
    private let cues: any Cues
    private var timer: (any DispatchSourceTimer)?
    private var startedAt: Date?

    init(exercises: [Exercise] = Ritual.exercises, cues: any Cues = SessionCues()) {
        self.exercises = exercises
        self.cues = cues
        reset()
    }

    func reset() {
        phases = TimelineBuilder.build(from: exercises)
        index = 0
        isDone = false
        remaining = phases.first?.seconds ?? 0
        startedAt = nil
    }

    func start() {
        guard !isRunning else { return }
        cues.prepare()
        isRunning = true
        if startedAt == nil { startedAt = Date(); enter() }
        scheduleTimer()
    }

    func pause() {
        isRunning = false
        timer?.cancel(); timer = nil
    }

    func resume() { start() }

    func stop() {
        pause()
        cues.release()
        reset()
    }

    private func scheduleTimer() {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 1, repeating: 1, leeway: .milliseconds(50))
        t.setEventHandler { [weak self] in MainActor.assumeIsolated { self?.tick() } }
        t.resume()
        timer = t
    }

    private func tick() {
        guard isRunning else { return }
        remaining -= 1
        if remaining <= 0 {
            if phase.kind == .work { cues.tick(.end) }
            index += 1
            if index >= phases.count { finish(); return }
            remaining = phases[index].seconds
            enter()
            return
        }
        if remaining <= Config.warnSeconds { cues.tick(.warn) }
    }

    private func enter() {
        guard phase.kind == .work else { return }
        cues.tick(.start)
    }

    private func finish() {
        pause()
        cues.release()
        isDone = true
        Health.storeCompletedWorkout(start: startedAt ?? Date(), end: Date())
    }

    var phase: Phase { phases[min(index, phases.count - 1)] }
}
