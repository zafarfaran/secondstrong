#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSCore
@testable import SSToday

/// Captures the coach mid-answer: each stage, then words arriving. SS_SNAPSHOT_DIR=/tmp/s swift test --filter StreamingSnapshot
@MainActor @Suite(.serialized) struct StreamingSnapshotTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil))
    func stages() async throws {
        let directory = try #require(ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"])
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)
        let model = TodayModel(hour: 13)
        model.animateCoach = false
        model.tab = .coach
        let host = NSHostingView(rootView: MainTabsContent(model: model))
        let window = NSWindow(contentRect: NSRect(x: 40, y: 40, width: 402, height: 874), styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = host
        window.orderFrontRegardless()
        func shot(_ name: String) {
            host.layoutSubtreeIfNeeded()
            guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return }
            host.cacheDisplay(in: host.bounds, to: rep)
            try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(directory)/\(name).png"))
        }
        func wait(_ s: Double) async throws { try await Task.sleep(for: .seconds(s)) }
        try await wait(0.8)
        let pic = NSImage(size: NSSize(width: 200, height: 200), flipped: false) { rect in
            NSColor(srgbRed: 0.93, green: 0.78, blue: 0.5, alpha: 1).setFill(); rect.fill(); return true
        }
        model.sendPhoto(try #require(pic.tiffRepresentation))
        try await wait(0.4); shot("s1-thinking")
        try await wait(1.0); shot("s2-reading")
        try await wait(0.9); shot("s3-spotting")
        try await wait(0.9); shot("s4-estimating")
        try await wait(1.6); shot("s5-writing")
        #expect(model.messages.last?.progress?.stage == .writing || model.messages.last?.progress == nil)
        try await wait(5.0); shot("s6-done")
        let last = try #require(model.messages.last)
        #expect(last.progress == nil && last.meal != nil && last.text.contains("28g"))
        // stop partway through a text answer
        model.draft = "Lunch ideas"; model.send()
        try await wait(2.0)
        #expect(model.isResponding)
        model.stop()
        try await wait(0.4); shot("t1-stopped")
        #expect(!model.isResponding && model.messages.last?.outcome == .stopped)
        // a text answer that breaks part way, then a retry that works
        model.draft = "/fail"; model.send()
        try await wait(3.2); shot("t2-failed")
        let broken = try #require(model.messages.last)
        #expect(broken.outcome == .failed(.network) && !broken.text.isEmpty)
        model.retry(broken)
        try await wait(4.0)
        #expect(model.messages.last?.outcome == .completed && model.messages.last?.progress == nil)
        // a photo it cannot read
        model.draft = "/failphoto"; model.send()
        model.sendPhoto(try #require(pic.tiffRepresentation))
        try await wait(4.0); shot("t3-photo-failed")
        #expect(model.messages.last?.outcome == .failed(.photo))
        window.close()
    }
}
#endif
