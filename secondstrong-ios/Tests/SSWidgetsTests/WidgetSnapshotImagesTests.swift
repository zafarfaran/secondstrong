#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSCore
import SSDesign
@testable import SSWidgets

/// Draws each widget at its real iPhone size in light and dark, in all three states. SS_SNAPSHOT_DIR=/tmp/w swift test --filter WidgetImages
@MainActor @Suite(.serialized) struct WidgetImagesTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil))
    func draw() throws {
        let directory = try #require(ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"])
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        let states: [(String, Int, Int)] = [("morning", 62, 9), ("goal", 88, 14), ("evening", 62, 20)]
        for dark in [false, true] {
            for (name, protein, hour) in states {
                let snap = WidgetSnapshot(coach: .miso, proteinGrams: protein, proteinTarget: 85, hour: hour, hideLockScreenNumbers: false)
                let hidden = WidgetSnapshot(coach: .miso, proteinGrams: protein, proteinTarget: 85, hour: hour, hideLockScreenNumbers: true)
                save(MisoSmallWidget(snap), 158, 158, home: true, dark, "\(directory)/small-\(name)-\(dark ? "dark" : "light").png")
                save(MisoMediumWidget(snap), 338, 158, home: true, dark, "\(directory)/medium-\(name)-\(dark ? "dark" : "light").png")
                if name == "morning" {
                    save(MisoLockCircle(snap), 76, 76, home: false, dark, "\(directory)/lockcircle-\(dark ? "dark" : "light").png")
                    save(MisoLockRectangle(snap), 172, 76, home: false, dark, "\(directory)/lockrect-\(dark ? "dark" : "light").png")
                    save(MisoLockCircle(hidden), 76, 76, home: false, dark, "\(directory)/lockcircle-hidden-\(dark ? "dark" : "light").png")
                    save(MisoLockRectangle(hidden), 172, 76, home: false, dark, "\(directory)/lockrect-hidden-\(dark ? "dark" : "light").png")
                }
            }
        }
    }

    private func save<V: View>(_ view: V, _ w: CGFloat, _ h: CGFloat, home: Bool, _ dark: Bool, _ path: String) {
        let content = view.padding(home ? 16 : 6).frame(width: w, height: h)
            .background(home ? Palette.ivory : Color.black.opacity(0.55))
            .foregroundStyle(home ? Palette.ink : .white)
            .clipShape(RoundedRectangle(cornerRadius: home ? 24 : 20))
        let host = NSHostingView(rootView: content)
        host.frame = NSRect(x: 0, y: 0, width: w, height: h)
        let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return }
        host.cacheDisplay(in: host.bounds, to: rep)
        try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
    }
}
#endif
