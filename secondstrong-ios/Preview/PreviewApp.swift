import AppKit
import SwiftUI
import SSOnboarding
import SSToday

/// Opens the onboarding in a phone-sized window, and the sign-in screens in light and dark, the loading screen on its own, and a gallery of every coach state.
/// Run with: make preview
@main
struct PreviewApp: App {
    @AppStorage("preview.appearance") private var appearance = "light"
    @State private var onboarded = ProcessInfo.processInfo.arguments.contains("--today")

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
        WindowGroup("Second Strong") {
            Group {
                if onboarded { MainTabsView() } else { OnboardingView { onboarded = true } }
            }
                .frame(width: 402, height: 874)
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
