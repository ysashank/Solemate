import SwiftUI
import HealthKit

@main
struct SolemateApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Health.ensureAuthorizationIfNeeded()
            }
        }
    }
}
