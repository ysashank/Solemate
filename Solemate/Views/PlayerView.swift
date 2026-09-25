import SwiftUI

struct PlayerView: View {
    @State private var vm = PlayerViewModel()
    @State private var resumeOnActive = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 32) {
                Text(isBreak ? "Coming up" : "In progress")
                    .foregroundStyle(Color.foregroundSecondary)
                    .opacity(isBreak ? 1 : 0)
                    .accessibilityHidden(!isBreak)

                Text(title)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isBreak ? Color.foregroundSecondary : Color.foregroundPrimary)

                VStack(spacing: 8) {
                    ForEach(subtitleLines(), id: \.self) { line in
                        Text(line)
                            .foregroundStyle(isBreak ? Color.foregroundSecondary : Color.foregroundTertiary)
                    }
                }

                Text(timeString(vm.remaining))
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.18,
                                  weight: .bold,
                                  design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .foregroundStyle(isBreak ? Color.timerRest : Color.foregroundPrimary)
                    .monospacedDigit()
                    .accessibilityLabel("\(vm.remaining) seconds remaining, \(title)")

                HStack(spacing: 40) {
                    Button {
                        vm.isRunning ? vm.pause() : vm.resume()
                    } label: {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundStyle(Color.foregroundTertiary)
                            .circleButton()
                    }
                    .accessibilityLabel(vm.isRunning ? "Pause" : "Resume")

                    Button {
                        vm.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title)
                            .foregroundStyle(Color.foregroundTertiary)
                            .circleButton()
                    }
                    .accessibilityLabel("Stop ritual")
                }
                .padding(.vertical, 24)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { ScreenManager.disableScreenSleep(); Health.ensureAuthorizationIfNeeded(); vm.start() }
        .onDisappear { ScreenManager.enableScreenSleep() }
        .onChange(of: scenePhase) { _, p in
            if p == .background, vm.isRunning { resumeOnActive = true; vm.pause() }
            else if p == .active, resumeOnActive { resumeOnActive = false; vm.resume() }
        }
        .sensoryFeedback(trigger: vm.feedback) { _, new in
            switch new.kind {
            case .start: .impact(weight: .heavy)
            case .end: .success
            case .warn: nil
            }
        }
        .fullScreenCover(item: Binding(get: { vm.completion.map(Completed.init) }, set: { _ in })) { done in
            CompletionView(completion: done.value) { dismiss() }
        }
        .navigationBarBackButtonHidden()
    }

    private struct Completed: Identifiable {
        let value: SessionCompletion
        var id: Date { value.completedAt }
        init(_ value: SessionCompletion) { self.value = value }
    }

    private var isBreak: Bool { vm.phase.kind != .work }

    private var title: String { vm.phase.exercise.title }

    private func subtitleLines() -> [String] {
        let p: Phase? = vm.phase.kind == .work ? vm.phase : nextWorkPhase()
        guard let p else { return [] }
        var lines: [String] = []
        if let side = p.side { lines.append("\(side) side") }
        var line = p.set > 0 ? "Set \(p.set) of \(p.exercise.sets)" : ""
        if let rep = p.rep, let total = p.exercise.reps {
            line += line.isEmpty ? "Rep \(rep) of \(total)" : " • Rep \(rep) of \(total)"
        }
        if !line.isEmpty { lines.append(line) }
        return lines
    }

    private func nextWorkPhase() -> Phase? {
        vm.phases[min(vm.index + 1, vm.phases.count)...].first { $0.kind == .work }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
