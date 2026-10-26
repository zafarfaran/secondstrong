#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSDesign
@testable import SSOnboarding

/// Saves every sign-in screen, light and dark. Set SS_SNAPSHOT_DIR to run it:
/// One screen per process (several windows crash): SS_SCREEN=door|email|inbox|returning|expired|invited SS_DARK=1.
/// SS_SNAPSHOT_DIR=/tmp/shots swift test --filter SignInScreens
@MainActor @Suite(.serialized) struct SignInScreensSnapshotTests {
    private let directory = ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"]

    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil && ProcessInfo.processInfo.environment["SS_SCREEN"] != nil))
    func oneScreen() async throws {
        let directory = try #require(directory)
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)
        let stages: [String: AuthStage] = ["door": .choose, "email": .email, "inbox": .sent, "returning": .returning, "expired": .expired, "invited": .invited]
        let env = ProcessInfo.processInfo.environment
        let name = env["SS_SCREEN"] ?? "door"
        let dark = env["SS_DARK"] == "1"
        let flow = OnboardingFlow()
        flow.previewAuth(try #require(stages[name]))
        let host = NSHostingView(rootView: AuthGate(flow: flow).frame(width: 390, height: 844))
        let window = NSWindow(contentRect: NSRect(x: 40, y: 40, width: 390, height: 844), styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        window.contentView = host
        window.orderFrontRegardless()
        try? await Task.sleep(for: .seconds(1.2))
        host.layoutSubtreeIfNeeded()
        if let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) {
            host.cacheDisplay(in: host.bounds, to: rep)
            try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(directory)/\(dark ? "dark" : "light")-\(name).png"))
        }
        window.close()
    }
}
#endif
