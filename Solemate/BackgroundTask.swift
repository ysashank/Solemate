//
//  BackgroundTask.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import UIKit

enum BackgroundTask {
    private static var id: UIBackgroundTaskIdentifier = .invalid

    static func begin(_ reason: String = "SolemateRun") {
        end()
        id = UIApplication.shared.beginBackgroundTask(withName: reason) {}
    }

    static func end() {
        guard id != .invalid else { return }
        UIApplication.shared.endBackgroundTask(id)
        id = .invalid
    }
}
