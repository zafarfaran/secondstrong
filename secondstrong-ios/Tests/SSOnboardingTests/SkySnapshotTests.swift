#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSDesign
@testable import SSOnboarding

/// Saves the night sky frozen at one moment, to judge the meteor. One moment per process (several windows crash):
/// SS_SKY_T=4.1 SS_SNAPSHOT_DIR=/tmp/shots swift test --filter SkySnapshot
@MainActor @Suite(.serialized) struct SkySnapshotTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SKY_T"] != nil && ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil))
    func frozenSky() async throws {
        let env = ProcessInfo.processInfo.environment
        let directory = try #require(env["SS_SNAPSHOT_DIR"])
        let t = try #require(Double(env["SS_SKY_T"] ?? ""))
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)
        let view = ZStack { Palette.ivory; PaperSky(dark: true, hillsTop: 465, reduceMotion: true, fixedTime: t) }.frame(width: 390, height: 844)
        let host = NSHostingView(rootView: view)
        let window = NSWindow(contentRect: NSRect(x: 40, y: 40, width: 390, height: 844), styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = host
        window.orderFrontRegardless()
        try? await Task.sleep(for: .seconds(0.6))
        host.layoutSubtreeIfNeeded()
        if let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) {
            host.cacheDisplay(in: host.bounds, to: rep)
            try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(directory)/sky-\(t).png"))
        }
        window.close()
    }
}
#endif
