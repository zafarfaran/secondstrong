import Testing
@testable import SSCore

@Suite struct MealEstimateTests {
    private let eggs = MealEstimate(name: "Eggs on toast", proteinGrams: 28, calories: 410)

    @Test func loggingAddsProteinAndCalories() {
        var s = TodaySummary.sample
        s.log(eggs)
        #expect(s.proteinGrams == 90 && s.caloriesEaten == 1500)
        #expect(s.proteinToGo == 0)
    }

    @Test func calorieFreeModeNeverShowsCalories() {
        #expect(eggs.summary(showCalories: true) == "28g protein · about 410 kcal")
        #expect(eggs.summary(showCalories: false) == "28g protein")
        #expect(!eggs.summary(showCalories: false).contains("kcal"))
    }

    @Test func turningCaloriesOffAndOnKeepsTheTarget() {
        var s = TodaySummary.sample
        s.setShowsCalories(false)
        #expect(s.calorieTarget == nil && s.caloriesLeft == nil)
        s.setShowsCalories(true, target: 1540)
        #expect(s.calorieTarget == 1540)
    }

    @Test func theCoachAnswersAMealPlainly() {
        let line = TodayLines.mealReply(eggs, summary: .sample)
        #expect(line.contains("28g") && !line.contains("!"))
        #expect(!line.lowercased().contains("weight"))
    }

    @Test func thePrototypeScannerCyclesThroughMadeUpMeals() {
        let first = MealEstimate.prototype(0), second = MealEstimate.prototype(1)
        #expect(first != second && MealEstimate.prototype(MealEstimate.samples.count) == first)
        #expect(first.proteinGrams > 0 && first.calories > 0)
    }
}
