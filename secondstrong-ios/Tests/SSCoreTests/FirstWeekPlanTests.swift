import Testing
@testable import SSCore

@Suite struct FirstWeekPlanTests {
    @Test func noteNamesFirstTrainingDayAndCoach() {
        var a = OnboardingAnswers()
        a.select(coach: .luna)
        a.toggle(day: .wed)
        a.toggle(day: .mon)
        let plan = FirstWeekPlan(a)
        #expect(plan.coachNote == "Mon first. Easy on rough mornings. — Luna")
        #expect(plan.trainingDays == [.mon, .wed])
    }

    @Test func summaryCountsSessions() {
        #expect(FirstWeekPlan.summary(dayCount: 3) == "3 × 20 minutes")
        #expect(FirstWeekPlan.summary(dayCount: 0) == "tap the days that usually work")
    }
}
