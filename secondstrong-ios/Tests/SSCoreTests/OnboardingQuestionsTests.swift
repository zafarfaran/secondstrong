import Testing
@testable import SSCore

@Suite struct OnboardingQuestionsTests {
    @Test func consentGatesTheNextScreen() {
        var a = OnboardingAnswers()
        #expect(!a.canContinue(from: .consent))
        a.consent(true)
        #expect(a.canContinue(from: .consent))
        a.consent(false)
        #expect(!a.canContinue(from: .consent))
    }

    private let today = BirthDate(year: 2026, month: 10, day: 21)!

    @Test func theAdultGateIsExactToTheDay() {
        var a = OnboardingAnswers()
        #expect(!a.canContinue(from: .birth, today: today))
        a.select(birthDate: BirthDate(year: 2008, month: 10, day: 22))
        #expect(!a.canContinue(from: .birth, today: today))
        a.select(birthDate: BirthDate(year: 2008, month: 10, day: 21))
        #expect(a.canContinue(from: .birth, today: today))
        a.select(birthDate: BirthDate(year: 1972, month: 3, day: 9))
        #expect(a.isAdult(on: today))
        a.select(birthDate: nil)
        #expect(!a.canContinue(from: .birth, today: today))
    }

    @Test func impossibleDatesAreRefused() {
        #expect(BirthDate(year: 1980, month: 2, day: 30) == nil)
        #expect(BirthDate(year: 1980, month: 2, day: 29) != nil)
        #expect(BirthDate(year: 1900, month: 2, day: 29) == nil)
        #expect(BirthDate(year: 2000, month: 2, day: 29) != nil)
        #expect(BirthDate(year: 1980, month: 13, day: 1) == nil)
    }

    @Test func ageCountsWholeYears() {
        let born = BirthDate(year: 1972, month: 3, day: 9)!
        #expect(born.age(on: today) == 54)
        #expect(born.age(on: BirthDate(year: 2026, month: 3, day: 8)!) == 53)
    }

    @Test func noneAndRatherNotSayStandAlone() {
        var a = OnboardingAnswers()
        a.toggle(safety: .diabetes)
        a.toggle(safety: .thyroid)
        #expect(a.safety == [.diabetes, .thyroid])
        a.toggle(safety: .none)
        #expect(a.safety == [.none])
        a.toggle(safety: .heart)
        #expect(a.safety == [.heart])
        a.toggle(safety: .noAnswer)
        #expect(a.safety == [.noAnswer])
        a.toggle(safety: .noAnswer)
        #expect(!a.canContinue(from: .safety))
    }

    @Test func conditionsGetAGPNoteButNeverBlock() {
        var a = OnboardingAnswers()
        a.toggle(safety: .kidney)
        #expect(a.showsGPNote)
        #expect(a.canContinue(from: .safety))
        #expect(a.asksForBody)
    }

    @Test func disorderedEatingMeansCalorieFreeAndNoBodyNumbers() {
        var a = OnboardingAnswers()
        a.toggle(safety: .eatingHistory)
        #expect(a.calorieFree)
        #expect(!a.asksForBody)
        #expect(a.canContinue(from: .body))
        a.write(intention: "Feel strong again")
        #expect(FirstWeekPlan(a).intention == nil)
        #expect(FirstWeekPlan(a).proteinGrams == FirstWeekPlan.defaultProteinGrams)
    }

    @Test func pregnancyRoutesOutOfBodyNumbers() {
        var a = OnboardingAnswers()
        a.toggle(safety: .pregnancy)
        #expect(!a.asksForBody)
        #expect(a.canContinue(from: .body))
        #expect(!a.calorieFree)
    }

    @Test func bodyNeedsSensibleNumbersOrASkip() {
        var a = OnboardingAnswers()
        #expect(!a.canContinue(from: .body))
        let tooShort = a.setBody(heightCm: 20, weightKg: 70)
        let tooHeavy = a.setBody(heightCm: 165, weightKg: 500)
        #expect(!tooShort && !tooHeavy)
        #expect(!a.canContinue(from: .body))
        let fine = a.setBody(heightCm: 165, weightKg: 70)
        #expect(fine)
        #expect(a.canContinue(from: .body))
        a.clearBody()
        #expect(!a.canContinue(from: .body))
        a.skipBody()
        #expect(a.weightKg == nil)
        #expect(a.canContinue(from: .body))
    }

    @Test func imperialInputConvertsToMetric() {
        #expect(abs(BodyMeasures.centimetres(feet: 5, inches: 5) - 165.1) < 0.01)
        #expect(abs(BodyMeasures.kilograms(pounds: 154) - 69.85) < 0.01)
    }

    @Test func trainingNeedsBothAnswers() {
        var a = OnboardingAnswers()
        a.select(experience: .tried)
        #expect(!a.canContinue(from: .training))
        a.select(equipment: .dumbbells)
        #expect(a.canContinue(from: .training))
    }

    @Test func intentionIsCappedAndAlwaysOptional() {
        var a = OnboardingAnswers()
        #expect(a.canContinue(from: .goals) == false)
        a.toggle(goal: .sleep)
        #expect(a.canContinue(from: .goals))
        a.write(intention: String(repeating: "x", count: 300))
        #expect(a.intention.count == OnboardingAnswers.maxIntentionLength)
    }

    @Test func proteinFollowsWeightWithinLimits() {
        #expect(FirstWeekPlan.protein(forWeightKg: nil) == 100)
        #expect(FirstWeekPlan.protein(forWeightKg: 70) == 85)
        #expect(FirstWeekPlan.protein(forWeightKg: 40) == 60)
        #expect(FirstWeekPlan.protein(forWeightKg: 200) == 140)
    }

    @Test func planEchoesHerWordsAndEquipment() {
        var a = OnboardingAnswers()
        a.write(intention: "  Carry my own shopping  ")
        a.toggle(day: .mon)
        a.toggle(day: .thu)
        a.select(equipment: .bands)
        let plan = FirstWeekPlan(a)
        #expect(plan.intention == "Carry my own shopping")
        #expect(plan.trainingLine == "2 × 20 minutes · bands or bodyweight")
    }
}
