import AppKit
import SwiftUI
import SSOnboarding

/// Opens the onboarding in a phone-sized window, and the sign-in screens in light and dark, the loading screen on its own, and a gallery of every coach state.
/// Run with: make preview
@main
struct PreviewApp: App {
    @AppStorage("preview.appearance") private var appearance = "light"

    private var scheme: ColorScheme? {
        switch appearance {
        case "dark": .dark
        case "light": .light
        default: nil
        }
    }

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup("Second Strong onboarding") {
            OnboardingView()
                .frame(width: 390, height: 844)
                .preferredColorScheme(scheme)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Picker("Appearance", selection: $appearance) {
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                            Text("System").tag("system")
                        }
                        .pickerStyle(.segmented)
                    }
                }
        }
        .windowResizability(.contentSize)

        Window("Sign-in screens", id: "signin") {
            SignInScreensPreview()
        }
        .windowResizability(.contentSize)

        Window("Loading screen", id: "loading") {
            LoadingScreenPreview().preferredColorScheme(scheme)
        }
        .windowResizability(.contentSize)

        Window("Mascot gallery", id: "gallery") {
            MascotGallery().preferredColorScheme(scheme)
        }
        .windowResizability(.contentSize)
    }
}
