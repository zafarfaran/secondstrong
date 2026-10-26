#if os(macOS)
import AppKit
import SwiftUI
import Testing
import SSCore
@testable import SSOnboarding

/// Plays the whole flow in an offscreen window and saves PNGs. Set SS_SNAPSHOT_DIR to run it:
/// SS_SNAPSHOT_DIR=/tmp/shots swift test --filter Playthrough   (light by default; SS_DARK=1 for dark mode)
@MainActor @Suite(.serialized) struct PlaythroughSnapshotTests {
    private let directory = ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"]

    private func pause(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }

    @Test(.enabled(if: ProcessInfo.processInfo.environment["SS_SNAPSHOT_DIR"] != nil))
    func playthrough() async throws {
        let directory = try #require(directory)
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.accessory)

        let flow = OnboardingFlow()
        let host = NSHostingView(rootView: OnboardingRun(flow: flow, onRestart: {}))
        let frame = NSRect(x: 40, y: 40, width: 390, height: 844)
        let window = NSWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: ProcessInfo.processInfo.environment["SS_DARK"] == "1" ? .darkAqua : .aqua)
        window.contentView = host
        window.orderFrontRegardless()

        func shot(_ name: String) {
            host.layoutSubtreeIfNeeded()
            guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { return }
            host.cacheDisplay(in: host.bounds, to: rep)
            try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(directory)/\(name).png"))
        }

        await pause(1.5); shot("00-door")
        flow.chooseEmail(); await pause(0.6)
        flow.authEmail = "anna.hart@example.com"; await pause(0.4); shot("00b-email")
        await flow.sendLink(); await pause(0.6); shot("00c-inbox")
        await flow.enter(code: "482913")
        await pause(1.0); shot("01-drawing-coach")
        await pause(3.5); shot("02-welcome")
        flow.next(); await pause(3.5); shot("03-consent")
        flow.agree(true); await pause(0.4)
        flow.next(); await pause(4.0); shot("04-coach")
        flow.pick(coach: .miso); await pause(1.0); shot("04b-miso-writing"); await pause(1.5); shot("04b-miso")
        flow.next(); await pause(4.5); shot("05-stage")
        flow.pick(stage: .peri); await pause(0.4)
        flow.next(); await pause(3.5); shot("06-goals")
        flow.toggle(goal: .stronger); flow.toggle(goal: .carry); flow.toggle(goal: .sleep); await pause(0.5)
        flow.answers.write(intention: "Carry my own shopping without thinking about it"); await pause(0.3); shot("07-goals-picked")
        flow.next(); await pause(3.5)
        flow.answers.select(birthDate: BirthDate(year: 1972, month: 3, day: 9)); await pause(0.3); shot("08-birth")
        flow.next(); await pause(3.5)
        flow.pick(safety: ProcessInfo.processInfo.environment["SS_EATING"] == "1" ? .eatingHistory : .thyroid); await pause(0.3); shot("09-safety")
        flow.next(); await pause(4.0)
        flow.answers.setBody(heightCm: 165, weightKg: 70); await pause(0.3); shot("10-body")
        flow.next(); await pause(3.5)
        flow.pick(experience: .tried); flow.pick(equipment: .dumbbells); await pause(0.4); shot("11-training")
        flow.next(); await pause(4.5); shot("12-days")
        for d in [Weekday.mon, .wed, .fri] { flow.toggle(day: d) }
        await pause(0.4); shot("13-days-picked")
        if flow.answers.isAsked(.activity) {
            flow.next(); await pause(3.5); flow.pick(activity: .some); await pause(0.3); shot("11a-activity")
            flow.next(); await pause(3.5); flow.pick(foodGoal: .cut); await pause(0.6); shot("11b-goal"); flow.setWeeklyKilos(0.4); await pause(0.5); shot("11b-goal-max"); flow.setWeeklyKilos(0.25)
            if ProcessInfo.processInfo.environment["SS_HABITS"] == "1" { flow.pick(foodView: .habitsOnly); await pause(0.5); shot("11b-goal-habits") }
        }
        flow.next(); await pause(4.5); shot("14a-building-mid")
        await pause(3.5); shot("14b-building-end")
        await pause(9.0); shot("14-plan")
        await pause(3.0); shot("15-plan-ready")
        flow.next(); await pause(4.5); shot("15b-paywall")
        flow.paywallTab = .helpers; flow.setHelpers(2); await pause(0.6); shot("15c-paywall-helpers")
        await flow.purchase(); await pause(4.5)
        flow.inviteName = "Sam"; flow.inviteMessage = "Thinking of you. Go gently."; await pause(0.4); shot("15d-invite")
        flow.finishOnboarding(); await pause(2.5); shot("16-overview")

        #expect(flow.step == OnboardingFlow.lastStep)
        #expect(flow.startReady)
        #expect(flow.ended)
        #expect(flow.answers.coach == .miso)
        window.close()
    }
}
#endif
