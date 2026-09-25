import SwiftUI

extension View {
    func circleButton() -> some View {
        frame(width: 100, height: 100)
            .overlay(Circle().stroke(Color.foregroundTertiary, lineWidth: 1))
            .clipShape(Circle())
            .shadow(radius: 1)
    }
}
