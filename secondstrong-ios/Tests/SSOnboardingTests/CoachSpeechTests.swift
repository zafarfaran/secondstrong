import Testing
import SSCore
@testable import SSOnboarding

@MainActor @Suite struct CoachSpeechTests {
    private func make() -> OnboardingFlow {
        let flow = OnboardingFlow()
        flow.reduceMotion = true
        return flow
    }

    @Test func sayingALineOpensABubbleAndHidingClosesIt() {
        let flow = make()
        flow.say("Hello there.")
        #expect(flow.speech?.text == "Hello there.")
        flow.hideSpeech()
        #expect(flow.speech == nil)
    }

    @Test func aNewLineReplacesTheOldOne() {
        let flow = make()
        flow.say("One.")
        let first = flow.speech?.id
        flow.say("Two.")
        #expect(flow.speech?.text == "Two.")
        #expect(flow.speech?.id != first)
    }

    @Test func theCoachStaysSilentWhereItHasNothingToSay() {
        let flow = make()
        flow.speakOnArrival(.welcome)
        #expect(flow.speech == nil)
        flow.speakOnArrival(nil)
        #expect(flow.speech == nil)
    }

    @Test func aCoachThatIsNotDockedDoesNotSpeakOnArrival() async {
        let flow = make()
        flow.speakOnArrival(.stage)
        try? await Task.sleep(for: .seconds(0.7))
        #expect(flow.speech == nil)
    }

    @Test func quietNudgesWaitWhileTheCoachIsSpeaking() {
        let flow = make()
        flow.heroVisible = true
        flow.say("Talking.")
        flow.nudgeIfQuiet(now: .now.addingTimeInterval(20))
        #expect(flow.heroMood == .idle)
    }
}
