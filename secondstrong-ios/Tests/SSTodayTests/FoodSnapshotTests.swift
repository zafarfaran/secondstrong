#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSCore
@testable import SSToday

/// Draws the Food tab and the camera offscreen. SS_SNAPSHOT_DIR=/tmp/shots swift test --filter FoodSnapshot
@MainActor @Suite(.serialized) struct FoodSnapshotTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil))
    func foodAndCamera() async throws {
        let directory = try #require(ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"])
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)
        let model = TodayModel(hour: 16)
        model.pace = 0
        model.animateCoach = false
        model.open(.food)
        let host = NSHostingView(rootView: MainTabsContent(model: model))
        let window = NSWindow(contentRect: NSRect(x: 40, y: 40, width: 402, height: 874), styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: ProcessInfo.processInfo.environment["SS_DARK"] == "1" ? .darkAqua : .aqua)
        window.contentView = host
        window.orderFrontRegardless()
        func shot(_ name: String) {
            host.layoutSubtreeIfNeeded()
            guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return }
            host.cacheDisplay(in: host.bounds, to: rep)
            try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(directory)/\(name).png"))
        }
        try await Task.sleep(for: .seconds(1.5)); shot("food")
        model.openCamera()
        try await Task.sleep(for: .seconds(0.8)); shot("camera")
        let flow = try #require(model.camera)
        flow.capture(nil)
        try await Task.sleep(for: .seconds(0.6)); shot("camera-result")
        model.setShowsCalories(false)
        try await Task.sleep(for: .seconds(0.3)); shot("camera-result-nocal")
        model.setShowsCalories(true)
        model.addFromCamera(flow.estimate)
        try await Task.sleep(for: .seconds(0.9)); shot("food-added")
        model.openCamera()
        let again = try #require(model.camera)
        again.capture(nil); try await Task.sleep(for: .milliseconds(200)); again.retake()
        again.capture(nil); try await Task.sleep(for: .milliseconds(200))
        again.capture(nil); try await Task.sleep(for: .seconds(0.6)); shot("camera-failed")
        model.closeCamera()
        model.pace = 1
        model.openCamera()
        let slow = try #require(model.camera)
        slow.capture(nil)
        try await Task.sleep(for: .seconds(1.3)); shot("camera-reading")
        try await Task.sleep(for: .seconds(1.6)); shot("camera-reading-done")
    }
}
#endif
