//
//  Haptics.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 31.08.25.
//

import UIKit

enum Haptics {
    private static let generator = UINotificationFeedbackGenerator()

    static func prepare() { generator.prepare() }
    static func start()   { generator.notificationOccurred(.success) } // set start
    static func end()     { generator.notificationOccurred(.warning) } // set end
}
