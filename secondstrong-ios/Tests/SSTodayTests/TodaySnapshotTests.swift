#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSCore
@testable import SSToday

/// Draws the Today and Coach tabs offscreen and saves PNGs. Set SS_SNAPSHOT_DIR to run it (SS_DARK=1 for dark mode):
/// SS_SNAPSHOT_DIR=/tmp/shots swift test --filter TodaySnapshot
@MainActor @Suite(.serialized) struct TodaySnapshotTests {
    private let directory = ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"]

    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil))
    func tabs() async throws {
        let directory = try #require(directory)
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)
        let hour = Int(ProcessInfo.processInfo.environment["SS_HOUR"] ?? "") ?? 9
        let model = TodayModel(hour: hour)
        model.pace = 0
        model.animateCoach = false
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
        try await Task.sleep(for: .seconds(1.2)); shot("today")
        model.toggle(.strength); try await Task.sleep(for: .seconds(0.6)); shot("today-ticked")
        #expect(model.unread == 2)
        model.open(.coach); try await Task.sleep(for: .seconds(0.9)); shot("coach")
        #expect(model.unread == 0)
        if let ask = model.messages.first(where: { !$0.replies.isEmpty }) {
            model.reply("Lunch ideas", to: ask)
            try await Task.sleep(for: .seconds(0.5))
            #expect(model.messages.count == 4, "\(model.messages.map(\.text))")
            try await Task.sleep(for: .seconds(1.6)); shot("coach-replied")
        }
        model.showAttach = true; try await Task.sleep(for: .seconds(0.6)); shot("coach-menu"); model.showAttach = false
        let pic = NSImage(size: NSSize(width: 200, height: 200), flipped: false) { rect in
            NSColor(srgbRed: 0.93, green: 0.78, blue: 0.5, alpha: 1).setFill(); rect.fill()
            NSColor(srgbRed: 0.98, green: 0.97, blue: 0.9, alpha: 1).setFill(); NSBezierPath(ovalIn: rect.insetBy(dx: 30, dy: 30)).fill(); return true
        }
        let photo = try #require(pic.tiffRepresentation)
        model.sendPhoto(photo)
        try await Task.sleep(for: .seconds(0.4))
        try await Task.sleep(for: .seconds(0.6)); shot("coach-scan")
        let meal = try #require(model.messages.last { $0.meal != nil })
        let before = model.summary.proteinGrams
        model.log(meal)
        #expect(model.summary.proteinGrams == before + 28)
        model.log(meal)
        #expect(model.summary.proteinGrams == before + 28, "a meal is only added once")
        try await Task.sleep(for: .seconds(0.8)); shot("coach-added")
        model.showProfile = true; try await Task.sleep(for: .seconds(0.7)); shot("profile")
        model.setShowsCalories(false)
        #expect(model.summary.caloriesLeft == nil)
        model.setShowsCalories(true)
        model.showProfile = false
        let session = VoiceSession(autoStart: false)
        model.voice = session
        session.phase = .speaking
        session.caption = "Aim for about thirty grams of protein."
        try await Task.sleep(for: .seconds(0.8)); shot("voice")
        session.phase = .listening; session.caption = "I'm listening."
        try await Task.sleep(for: .seconds(0.6)); shot("voice-listening")
        model.closeVoice()
        model.showCheckIns = true; try await Task.sleep(for: .seconds(0.7)); shot("checkins")
        model.settings.midday = false
        #expect(!model.messages.contains { $0.kind == .midday })
        window.close()
    }
}
#endif
