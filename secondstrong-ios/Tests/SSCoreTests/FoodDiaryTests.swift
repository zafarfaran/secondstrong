import Foundation
import Testing
@testable import SSCore

struct FoodDiaryTests {
    @Test func theSampleDayMatchesTheTodayNumbers() {
        let day = FoodDiary.sample
        #expect(day.protein == TodaySummary.sample.proteinGrams)
        #expect(day.calories == TodaySummary.sample.caloriesEaten)
    }

    @Test func entriesStayInTimeOrder() {
        var day = FoodDiary.sample
        day.add(MealEstimate(name: "Soup", proteinGrams: 12, calories: 200), minute: 10 * 60)
        #expect(day.entries.map(\.minute) == day.entries.map(\.minute).sorted())
        #expect(day.entries.contains { $0.name == "Soup" })
    }

    @Test func nextMealFollowsTheLastOne() {
        #expect(FoodDiary.next(afterMinute: 8 * 60 + 40)?.title == "Lunch")
        #expect(FoodDiary.next(afterMinute: 12 * 60 + 40)?.title == "Snack")
        #expect(FoodDiary.next(afterMinute: 15 * 60 + 30)?.title == "Dinner")
        #expect(FoodDiary.next(afterMinute: 19 * 60) == nil)
    }

    @Test func theCameraNamesTheMealByTheClock() {
        #expect(FoodDiary.slotName(minute: 8 * 60) == "Breakfast")
        #expect(FoodDiary.slotName(minute: 12 * 60 + 40) == "Lunch")
        #expect(FoodDiary.slotName(minute: 16 * 60) == "Snack")
        #expect(FoodDiary.slotName(minute: 19 * 60) == "Dinner")
    }

    @Test func mealTimeIsPlain() {
        #expect(FoodDiary.clock(minute: 8 * 60 + 5) == "8:05")
        #expect(FoodDiary.clock(minute: 12 * 60 + 40) == "12:40")
        #expect(FoodDiary.clock(minute: 15 * 60 + 30) == "3:30")
    }

    @Test func misoNoteFollowsProgressAndStaysShort() {
        for protein in [0, 30, 45, 62, 80, 85, 100] {
            let line = FoodDiary.note(protein: protein, target: 85, afterMinute: 15 * 60)
            #expect(line.count <= 60)
        }
        #expect(FoodDiary.note(protein: 85, target: 85, afterMinute: 12 * 60).contains("made it"))
        #expect(FoodDiary.note(protein: 62, target: 85, afterMinute: 15 * 60).contains("23g"))
        #expect(!FoodDiary.note(protein: 20, target: 85, afterMinute: 9 * 60).contains("kcal"))
    }

    @Test func weekStripStartsOnMondayAndMarksToday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let thursday = calendar.date(from: DateComponents(year: 2026, month: 10, day: 29))!
        let week = WeekStrip.days(today: thursday, todayFraction: 0.73, calendar: calendar)
        #expect(week.map(\.initial) == ["M", "T", "W", "T", "F", "S", "S"])
        #expect(week.map(\.dayOfMonth) == [26, 27, 28, 29, 30, 31, 1])
        #expect(week.filter(\.isToday).count == 1 && week[3].isToday)
        #expect(week[3].fraction == 0.73)
        #expect(week[4...].allSatisfy { $0.fraction == 0 })
    }

    @Test func portionsScaleTheEstimate() {
        let meal = MealEstimate(name: "Eggs", proteinGrams: 28, calories: 480)
        #expect(meal.scaled(by: .medium) == meal)
        #expect(meal.scaled(by: .small).proteinGrams == 21 && meal.scaled(by: .small).calories == 360)
        #expect(meal.scaled(by: .large).proteinGrams == 36)
    }

    @Test func takingAnItemOffLowersTheNumbersAndRenamingKeepsThem() {
        let meal = MealEstimate(name: "Plate", proteinGrams: 40, calories: 400, items: ["A", "B", "C", "D"])
        let less = meal.adjusted(portion: .medium, removing: ["D"])
        #expect(less.proteinGrams == 30 && less.items == ["A", "B", "C"])
        let named = meal.adjusted(portion: .large, removing: [], named: "Lunch")
        #expect(named.name == "Lunch" && named.proteinGrams == 52)
        #expect(MealEstimate(name: "x", proteinGrams: 10, calories: 100).adjusted(portion: .medium, removing: ["z"]).proteinGrams == 10)
    }
}
