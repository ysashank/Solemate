
//
//  PlayerView.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import SwiftUI

struct PlayerView: View {
    @StateObject private var vm = PlayerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 32) {
                
                // 1. Indicator
                if (vm.phase.kind == .prep || vm.phase.kind == .restSet) {
                    Text("Coming up")
                        .foregroundColor(.primary)
                } else {
                    Text("In progress")
                        .opacity(0)
                }
                
                // 2. Exercise Title -- Always show current exercise title (work) or next exercise title (prep/rest)
                Text(getExerciseTitle())
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor((vm.phase.kind == .prep || vm.phase.kind == .restSet) ? .gray : .primary)
                
                // 3. Subtitle: Show specific details (set, rep, side info)
                VStack(spacing: 8) {
                    ForEach(getSubtitleLines(), id: \.self) { line in
                        Text(line)
                            .foregroundColor((vm.phase.kind == .prep || vm.phase.kind == .restSet) ? .gray : .secondary)
                    }
                }

                // 4. Timer
                Text(timeString(vm.remaining))
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.18,
                                  weight: .bold,
                                  design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .foregroundColor((vm.phase.kind == .prep || vm.phase.kind == .restSet) ? .yellow : .primary)
                    .accessibilityLabel("Time remaining \(vm.remaining) seconds")

                // 5. Actions
                HStack(spacing: 40) {
                    Button {
                        vm.isRunning ? vm.pause() : vm.resume()
                    } label: {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                            .overlay(Circle()
                                .stroke(Color.gray, lineWidth: 1)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 1)
                    }
                    .disabled(vm.isDone)

                    Button {
                        vm.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                            .overlay(Circle()
                                .stroke(Color.gray, lineWidth: 1)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 1)
                    }
                }
                .padding(.vertical, 24)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { vm.start() }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isDone { Text("Complete") }
            }
        }
    }

    private func getExerciseTitle() -> String {
        switch vm.phase.kind {
        case .prep, .restSet:
            return vm.phase.nextTitle ?? vm.phase.exercise.title
        case .work:
            return vm.phase.exercise.title
        case .done:
            return "Complete"
        }
    }
    
    private func getSubtitleLines() -> [String] {
        var lines: [String] = []
        
        switch vm.phase.kind {
        case .work:
            // Show current work phase details
            if let side = vm.phase.side {
                lines.append("\(side) side")
            }
            
            if vm.phase.set > 0 {
                var setLine = "Set \(vm.phase.set) of \(vm.phase.exercise.sets)"
                if let rep = vm.phase.rep, let totalReps = vm.phase.exercise.reps {
                    setLine += " • Rep \(rep) of \(totalReps)"
                }
                lines.append(setLine)
            } else if let rep = vm.phase.rep, let totalReps = vm.phase.exercise.reps {
                lines.append("Rep \(rep) of \(totalReps)")
            }
            
        case .prep, .restSet:
            // Show next work phase details
            let nextPhaseInfo = getNextPhaseInfo()
            if let nextSide = nextPhaseInfo.side {
                lines.append("\(nextSide) side")
            }
            
            if let nextSetInfo = nextPhaseInfo.setInfo {
                var setLine = nextSetInfo
                if let nextRep = nextPhaseInfo.rep, let nextPhase = getNextWorkPhase(), let totalReps = nextPhase.exercise.reps {
                    setLine += " • Rep \(nextRep) of \(totalReps)"
                }
                lines.append(setLine)
            } else if let nextRep = nextPhaseInfo.rep, let nextPhase = getNextWorkPhase(), let totalReps = nextPhase.exercise.reps {
                lines.append("Rep \(nextRep) of \(totalReps)")
            }
            
        case .done:
            break
        }
        
        return lines
    }
    
    private func getNextWorkPhase() -> Phase? {
        let nextIndex = vm.index + 1
        guard nextIndex < vm.phases.count else { return nil }
        
        // Find the next work phase
        for i in nextIndex..<vm.phases.count {
            if vm.phases[i].kind == .work {
                return vm.phases[i]
            }
        }
        return nil
    }
    
    private func getNextPhaseInfo() -> (side: String?, rep: Int?, setInfo: String?) {
        let nextWorkPhase = getNextWorkPhase()
        
        var side: String? = nil
        var rep: Int? = nil
        var setInfo: String? = nil
        
        if let nextPhase = nextWorkPhase {
            side = nextPhase.side
            rep = nextPhase.rep
            if nextPhase.set > 0 {
                setInfo = "Set \(nextPhase.set) of \(nextPhase.exercise.sets)"
            }
        }
        
        return (side: side, rep: rep, setInfo: setInfo)
    }

    private func timeString(_ s: Int) -> String {
        let m = s / 60, r = s % 60
        return String(format: "%02d:%02d", m, r)
    }
}

#Preview {
    PlayerView()
}
