import Foundation
import Testing
import SSCore
@testable import SSOnboarding

@MainActor @Suite struct IdleNudgeTests {
    private func make() -> OnboardingFlow {
        let flow = OnboardingFlow()
        flow.heroVisible = true
        return flow
    }

    @Test func nothingHappensWhileSomeoneIsStillActive() {
        let flow = make()
        flow.nudgeIfQuiet(now: Date().addingTimeInterval(2))
        #expect(flow.heroMood == .idle)
    }

    @Test func aQuietPauseMakesTheCoachDoAnIdleMove() {
        let flow = make()
        flow.nudgeIfQuiet(now: Date().addingTimeInterval(7))
        #expect(flow.heroMood == .idleLook)
    }

    @Test func movesTakeTurnsAndKeepTheirDistance() {
        let flow = make()
        let start = Date()
        flow.nudgeIfQuiet(now: start.addingTimeInterval(7))
        flow.nudgeIfQuiet(now: start.addingTimeInterval(9))
        #expect(flow.heroMood == .idleLook)
        flow.nudgeIfQuiet(now: start.addingTimeInterval(15))
        #expect(flow.heroMood == .idleYawn)
        flow.nudgeIfQuiet(now: start.addingTimeInterval(23))
        #expect(flow.heroMood == .idleBounce)
        flow.nudgeIfQuiet(now: start.addingTimeInterval(31))
        #expect(flow.heroMood == .idleLook)
    }

    @Test func touchingSomethingStartsTheWaitAgain() {
        let flow = make()
        flow.noteActivity()
        flow.nudgeIfQuiet(now: Date().addingTimeInterval(4))
        #expect(flow.heroMood == .idle)
    }

    @Test func noCoachOnScreenMeansNoMove() {
        let flow = OnboardingFlow()
        flow.nudgeIfQuiet(now: Date().addingTimeInterval(20))
        #expect(flow.heroMood == .idle)
        #expect(flow.companionMood == .idle)
    }
}
