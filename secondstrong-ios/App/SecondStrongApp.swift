import SwiftUI
import SSOnboarding

/// Composition root. Wires features together; holds no feature logic.
@main
struct SecondStrongApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView()
        }
    }
}
