//
//  PlayerViewModel.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import Foundation

final class PlayerViewModel: ObservableObject {
    @Published private(set) var phases: [Phase] = []
    @Published private(set) var index: Int = 0
    @Published private(set) var remaining: Int = 0
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isDone: Bool = false

    private var timer: DispatchSourceTimer?
    private var activeSeconds: Int = 0 // only work phases
    private var isNewPhase: Bool = true // track if we just entered this phase

    init() { reset() }

    func reset() {
        phases = TimelineBuilder.build(from: Ritual.exercises)
        index = 0
        isDone = false
        remaining = phases.first?.seconds ?? 0
        isNewPhase = true
        activeSeconds = 0
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        BackgroundTask.begin()
        scheduleTimer()
    }

    func pause() {
        isRunning = false
        timer?.cancel(); timer = nil
        BackgroundTask.end()
    }

    func resume() { start() }

    func stop() {
        pause()
        reset()
    }

    private func scheduleTimer() {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 1, repeating: 1, leeway: .milliseconds(50))
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume()
        timer = t
    }

    private func tick() {
        guard isRunning else { return }
        
        // Decrement first (so sounds align with what will be displayed)
        remaining -= 1
        
        // Account for elapsed work time
        if phase.kind == .work && remaining >= 0 {
            activeSeconds += 1
        }
        
        // Check if we need to transition to next phase
        if remaining < 0 {
            // Move to next phase
            index += 1
            if index >= phases.count {
                finish()
                return
            }
            remaining = phases[index].seconds
            isNewPhase = true
        }
        
        // Now play sounds based on what's about to be displayed
        let current = phase
        switch current.kind {
        case .prep, .restSet:
            // Warn sound for each second
            if remaining > 0 {
                SoundFX.shared.playWarn()
            }
            
        case .work:
            // Start sound/haptic when entering work phase
            if isNewPhase && remaining >= 0 {
                Haptics.prepare()
                SoundFX.shared.playStart()
                Haptics.start()
                isNewPhase = false
            }
            // End sound when hitting 0 (last second of work)
            else if remaining == 0 {
                SoundFX.shared.playEnd()
                Haptics.end()
            }
            // Warn for seconds 5, 4, 3, 2, 1 (not 0)
            else if remaining <= 4 && remaining > 0 {
                SoundFX.shared.playWarn()
            }
            
        case .done:
            break
        }
        
        if isNewPhase && current.kind != .work {
            isNewPhase = false
        }
    }

    private func finish() {
        pause()
        isDone = true
        Health.storeCompletedWorkout(duration: activeSeconds)
    }

    var phase: Phase { phases[min(index, phases.count - 1)] }

    var exerciseProgress: Double {
        let ex = phase.exercise
        let idx = index
        let totalWork = phases.filter { $0.exercise == ex && $0.kind == .work }.count
        let doneWork  = phases.prefix(idx).filter { $0.exercise == ex && $0.kind == .work }.count
        return totalWork == 0 ? 0 : Double(doneWork) / Double(totalWork)
    }
}
