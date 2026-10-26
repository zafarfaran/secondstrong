import Foundation
import Testing
@testable import SSCore

@Suite struct CoachLinesTests {
    private let spoken: [OnboardingStep] = [.stage, .goals, .birth, .safety, .body, .training, .activity, .days, .plan]

    @Test func everyScreenAfterTheCoachPickHasLines() {
        for step in spoken { #expect(!CoachLines.lines(for: step, coachName: "Miso").isEmpty, "\(step)") }
    }

    @Test func screensWithoutACoachStaySilent() {
        for step in [OnboardingStep.welcome, .consent, .coach, .building, .paywall, .invite] {
            #expect(CoachLines.lines(for: step, coachName: "Miso").isEmpty, "\(step)")
        }
    }

    @Test func linesFollowTheVoiceRules() {
        let banned = ["!", " just ", "journey", "reset", "weight loss", "lose ", "diet", "calorie", "{name}"]
        for step in spoken {
            for line in CoachLines.lines(for: step, coachName: "Miso") {
                #expect(line.count <= 42, "\(line)")
                for word in banned { #expect(!line.lowercased().contains(word), "\(line) has \(word)") }
            }
        }
    }

    @Test func theCoachIntroducesItselfOnTheFirstScreenItSpeaksOn() {
        #expect(CoachLines.lines(for: .stage, coachName: "Otto")[0].hasPrefix("I'm Otto"))
    }

    @Test func longerLinesStayUpLonger() {
        #expect(CoachLines.seconds(for: String(repeating: "x", count: 100)) > CoachLines.seconds(for: "Short."))
    }
}
