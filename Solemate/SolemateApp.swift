//
//  SolemateApp.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

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
