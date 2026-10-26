import Testing
@testable import SSCore

@Suite struct EnergyPlanTests {
    private let today = BirthDate(year: 2026, month: 10, day: 24)!

    /// Fake member: 54, 165 cm, 70 kg, three strength days.
    private func answers(activity: ActivityLevel = .some, goal: FoodGoal = .cut, kilos: Double = 0.25,
                         heightCm: Double = 165, weightKg: Double = 70, born: BirthDate = BirthDate(year: 1972, month: 3, day: 9)!) -> OnboardingAnswers {
        var a = OnboardingAnswers()
        a.select(birthDate: born)
        a.setBody(heightCm: heightCm, weightKg: weightKg)
        for day in [Weekday.mon, .wed, .fri] { a.toggle(day: day) }
        a.select(activity: activity)
        a.select(foodGoal: goal)
        a.select(weeklyKilos: kilos)
        return a
    }

    @Test func maintenanceFollowsTheFormula() throws {
        let plan = try #require(EnergyPlan(answers(), today: today))
        #expect(plan.maintenance == 1810)
        #expect(plan.range == 1690...1930)
    }

    @Test func moreActivityMeansMoreMaintenance() throws {
        let sitting = try #require(EnergyPlan(answers(activity: .sit), today: today))
        let physical = try #require(EnergyPlan(answers(activity: .hard), today: today))
        #expect(physical.maintenance > sitting.maintenance)
    }

    @Test func goalsMoveTheTargetGently() throws {
        #expect(try #require(EnergyPlan(answers(goal: .hold), today: today)).target == 1810)
        #expect(try #require(EnergyPlan(answers(goal: .cut), today: today)).target == 1540)
        #expect(try #require(EnergyPlan(answers(goal: .gain), today: today)).target == 2030)
    }

    @Test func theFloorHoldsWhateverThePace() throws {
        let plan = try #require(EnergyPlan(answers(activity: .sit, goal: .cut, kilos: 0.4, heightCm: 155, weightKg: 60,
                                                   born: BirthDate(year: 1976, month: 1, day: 1)!), today: today))
        #expect(plan.target == EnergyPlan.floorKcal)
        #expect(plan.clampedByFloor)
    }

    @Test func theSliderIsCappedAndSnapsToFiveHundredGrams() {
        var a = answers(goal: .cut)
        a.select(weeklyKilos: 9)
        #expect(a.weeklyKilos == 0.4)
        a.select(weeklyKilos: 0)
        #expect(a.weeklyKilos == 0.05)
        a.select(weeklyKilos: 0.27)
        #expect(a.weeklyKilos == 0.25)
        a.select(foodGoal: .gain)
        #expect(a.weeklyKilos == FoodGoal.gain.defaultWeeklyKilos)
        a.select(weeklyKilos: 5)
        #expect(a.weeklyKilos == 0.2)
    }

    @Test func choosingAGoalResetsThePaceToItsDefault() {
        var a = answers(goal: .cut, kilos: 0.4)
        a.select(foodGoal: .cut)
        #expect(a.weeklyKilos == FoodGoal.cut.defaultWeeklyKilos)
    }

    @Test func targetForAnyPaceNeverCrossesTheFloor() {
        let slow = EnergyPlan.target(maintenance: 1810, goal: .cut, weeklyKilos: 0.1)
        let fast = EnergyPlan.target(maintenance: 1810, goal: .cut, weeklyKilos: 0.4)
        #expect(slow.kcal == 1700 && !slow.clamped)
        #expect(fast.kcal == EnergyPlan.floorKcal && fast.clamped)
        #expect(EnergyPlan.target(maintenance: 1810, goal: .gain, weeklyKilos: 0.2).kcal == 2030)
        #expect(EnergyPlan.target(maintenance: 1810, goal: .hold, weeklyKilos: 0.2).kcal == 1810)
    }

    @Test func maintenanceIsKnownBeforeAGoalIsChosen() {
        var a = answers()
        #expect(EnergyPlan.maintenance(for: a, today: today) == 1810)
        a = OnboardingAnswers()
        #expect(EnergyPlan.maintenance(for: a, today: today) == nil)
    }

    @Test func noNumbersWithoutBodyAnswers() {
        var skipped = answers()
        skipped.skipBody()
        #expect(EnergyPlan(skipped, today: today) == nil)
        #expect(!skipped.asksForEnergy)
    }

    @Test func safetyRoutesOutOfCalorieTargets() {
        var eating = answers()
        eating.toggle(safety: .eatingHistory)
        #expect(EnergyPlan(eating, today: today) == nil)
        var pregnant = answers()
        pregnant.toggle(safety: .pregnancy)
        #expect(EnergyPlan(pregnant, today: today) == nil)
    }

    @Test func habitsOnlyHidesCalories() {
        var a = answers()
        a.select(foodView: .habitsOnly)
        #expect(!a.showsCalories)
        a.select(foodView: .calories)
        #expect(a.showsCalories)
        #expect(OnboardingAnswers().foodView == .calories)
    }

    @Test func energyScreensAreAskedOnlyWhenTheyCanBeUsed() {
        var a = answers()
        #expect(a.isAsked(.activity) && a.isAsked(.goal))
        a.toggle(safety: .eatingHistory)
        #expect(!a.isAsked(.activity) && !a.isAsked(.goal))
        #expect(a.isAsked(.days))
    }

    @Test func energyScreensNeedAnAnswerBeforeContinuing() {
        var a = OnboardingAnswers()
        #expect(!a.canContinue(from: .activity) && !a.canContinue(from: .goal))
        a.select(activity: .some); a.select(foodGoal: .hold)
        #expect(a.canContinue(from: .activity) && a.canContinue(from: .goal))
    }

    @Test func choosingNoCalorieNumbersNeedsNoGoal() {
        var a = OnboardingAnswers()
        a.select(foodView: .habitsOnly)
        #expect(a.canContinue(from: .goal))
    }
}
