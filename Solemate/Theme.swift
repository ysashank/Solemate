import SwiftUI
import UIKit

extension Color {
    static let backgroundPrimary = Color(UIColor.systemBackground)

    static let foregroundPrimary = Color(UIColor.label)
    static let foregroundSecondary = Color(UIColor.secondaryLabel)
    static let foregroundTertiary = Color(UIColor.tertiaryLabel)

    static let buttonSurface = Color(UIColor.tertiarySystemFill)

    static let timerRest = Color(UIColor.systemYellow)
    static let timerPrep = Color(UIColor.systemRed)
}

extension View {
    func circleButton() -> some View {
        frame(width: 100, height: 100)
            .overlay(Circle().stroke(Color.foregroundTertiary, lineWidth: 1))
            .clipShape(Circle())
            .shadow(radius: 1)
    }
}
