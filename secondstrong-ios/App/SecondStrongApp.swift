import SwiftUI
import SSOnboarding
import SSToday

/// Composition root. Wires features together; holds no feature logic.
@main
struct SecondStrongApp: App {
    @State private var onboarded = false

    var body: some Scene {
        WindowGroup {
            if onboarded {
                MainTabsView()
            } else {
                OnboardingView { onboarded = true }
            }
        }
    }
}
