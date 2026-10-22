import Testing
@testable import SSCore

@Suite struct OnboardingAnswersTests {
    @Test func nameFollowsCoachUntilEdited() {
        var a = OnboardingAnswers()
        a.select(coach: .luna)
        #expect(a.name == "Luna")
        a.rename("Sam")
        a.select(coach: .otto)
        #expect(a.name == "Sam")
        #expect(a.coach == .otto)
    }

    @Test func aFieldEchoingTheNameDoesNotLockIt() {
        var a = OnboardingAnswers()
        a.rename(a.name)
        a.select(coach: .miso)
        #expect(a.name == "Miso")
        a.rename("Sam")
        a.rename("Luna")
        a.select(coach: .otto)
        #expect(a.name == "Otto")
    }

    @Test func blankNameFallsBackToCoach() {
        var a = OnboardingAnswers()
        a.rename("   ")
        #expect(a.displayName == "Bramble")
    }

    @Test func nameIsCappedAtFourteen() {
        var a = OnboardingAnswers()
        a.rename("A very long coach name")
        #expect(a.name.count == OnboardingAnswers.maxNameLength)
    }

    @Test func fourthGoalIsRefused() {
        var a = OnboardingAnswers()
        let first = a.toggle(goal: .stronger)
        let second = a.toggle(goal: .sleep)
        let third = a.toggle(goal: .habits)
        let fourth = a.toggle(goal: .carry)
        #expect(first && second && third && !fourth)
        #expect(a.goals == [.stronger, .sleep, .habits])
        a.toggle(goal: .stronger)
        #expect(a.goals == [.sleep, .habits])
    }

    @Test func everyGoalHasAThemeAndNoneIsAboutWeight() {
        for goal in Goal.allCases {
            #expect(!goal.title.isEmpty)
            #expect(!goal.title.lowercased().contains("weight"))
            _ = goal.theme
        }
        #expect(Goal.sleep.theme == .sleep)
    }

    @Test func daysStayOrderedAndCapAtFour() {
        var a = OnboardingAnswers()
        for d in [Weekday.fri, .mon, .wed, .sun] { a.toggle(day: d) }
        #expect(a.days == [.mon, .wed, .fri, .sun])
        let fifth = a.toggle(day: .tue)
        #expect(!fifth)
        #expect(a.days.count == 4)
    }

    @Test func continueGatesFollowTheChoices() {
        var a = OnboardingAnswers()
        #expect(a.canContinue(from: .coach))
        #expect(!a.canContinue(from: .stage))
        #expect(!a.canContinue(from: .goals))
        #expect(!a.canContinue(from: .days))
        a.select(stage: .peri)
        a.toggle(goal: .energy)
        a.toggle(day: .mon)
        #expect(a.canContinue(from: .stage))
        #expect(a.canContinue(from: .goals))
        #expect(!a.canContinue(from: .days))
        a.toggle(day: .thu)
        #expect(a.canContinue(from: .days))
    }
}

@Suite struct StageAcknowledgementTests {
    @Test func everyStageHasAWarmLine() {
        for stage in Stage.allCases { #expect(!stage.acknowledgement.isEmpty) }
        #expect(Stage.surg.acknowledgement == "Thank you for telling me. We'll go gently.")
    }
}
