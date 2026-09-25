import SwiftUI

struct PlayerView: View {
    @State private var vm = PlayerViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var resumeOnActive = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 32) {

                if (vm.phase.kind == .prep || vm.phase.kind == .restSet) {
                    Text("Coming up")
                        .foregroundColor(.foregroundPrimary)
                } else {
                    Text("In progress")
                        .opacity(0)
                }

                Text(title())
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor((vm.phase.kind == .prep || vm.phase.kind == .restSet) ? .foregroundSecondary : .foregroundPrimary)

                VStack(spacing: 8) {
                    ForEach(subtitleLines(), id: \.self) { line in
                        Text(line)
                            .foregroundColor((vm.phase.kind == .prep || vm.phase.kind == .restSet) ? .foregroundSecondary : .foregroundTertiary)
                    }
                }

                Text(timeString(vm.remaining))
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.18,
                                  weight: .bold,
                                  design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .foregroundColor(timerColor)
                    .accessibilityLabel("Time remaining \(vm.remaining) seconds")

                HStack(spacing: 40) {
                    Button {
                        vm.isRunning ? vm.pause() : vm.resume()
                    } label: {
                        Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.foregroundTertiary)
                            .circleButton()
                    }
                    .disabled(vm.isDone)

                    Button {
                        vm.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title)
                            .foregroundColor(.foregroundTertiary)
                            .circleButton()
                    }
                }
                .padding(.vertical, 24)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { ScreenManager.disableScreenSleep(); vm.start() }
        .onDisappear { ScreenManager.enableScreenSleep() }
        .onChange(of: scenePhase) { _, p in
            if p == .background, vm.isRunning { resumeOnActive = true; vm.pause() }
            else if p == .active, resumeOnActive { resumeOnActive = false; vm.resume() }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if vm.isDone { Text("Complete") }
            }
        }
    }

    private var timerColor: Color {
        switch vm.phase.kind {
        case .prep: .timerPrep
        case .restSet: .timerRest
        default: .foregroundPrimary
        }
    }

    private func title() -> String {
        vm.phase.kind == .done ? "Complete" : vm.phase.exercise.title
    }

    private func subtitleLines() -> [String] {
        let p: Phase?
        switch vm.phase.kind {
        case .work: p = vm.phase
        case .prep, .restSet: p = nextWorkPhase()
        case .done: p = nil
        }
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
        let m = s / 60, r = s % 60
        return String(format: "%02d:%02d", m, r)
    }
}

#Preview {
    PlayerView()
}
