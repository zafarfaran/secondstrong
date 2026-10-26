import Testing
@testable import SSCore

@Suite struct TodaySummaryTests {
    private func summary(protein: Int = 62, calories: Int? = 1540, eaten: Int = 1090, steps: Int = 4820) -> TodaySummary {
        TodaySummary(name: "Anna", coach: .miso, proteinGrams: protein, proteinTarget: 85, caloriesEaten: eaten, calorieTarget: calories,
                     steps: steps, stepTarget: 8000, done: [.movement, .sleep], session: TrainingSession(title: "Upper body", minutes: 20, detail: "Dumbbells at home"))
    }

    @Test func fractionsStayBetweenZeroAndOne() {
        #expect(summary().proteinFraction == 62.0 / 85.0)
        #expect(summary(protein: 200).proteinFraction == 1)
        #expect(summary(steps: 20_000).stepsFraction == 1)
        #expect(summary(protein: 0).proteinFraction == 0)
    }

    @Test func caloriesLeftIsHiddenInCalorieFreeMode() {
        #expect(summary().caloriesLeft == 450)
        #expect(summary(calories: nil).caloriesLeft == nil)
        #expect(summary(eaten: 2000).caloriesLeft == 0)
    }

    @Test func proteinToGoNeverGoesNegative() {
        #expect(summary().proteinToGo == 23)
        #expect(summary(protein: 90).proteinToGo == 0)
    }

    @Test func habitsToggleAndCount() {
        var s = summary()
        #expect(s.habitsDone == 2)
        s.toggle(.strength)
        #expect(s.habitsDone == 3 && s.done.contains(.strength))
        s.toggle(.strength)
        #expect(s.habitsDone == 2)
    }

    @Test func dayPartsFollowTheClock() {
        #expect(DayPart.at(hour: 7) == .morning && DayPart.at(hour: 13) == .afternoon)
        #expect(DayPart.at(hour: 19) == .evening && DayPart.at(hour: 23) == .night && DayPart.at(hour: 3) == .night)
        #expect(DayPart.morning.greeting == "Good morning" && DayPart.night.greeting == "Good evening")
        #expect(DayPart.at(hour: 9).usesMorningScene && !DayPart.at(hour: 18).usesMorningScene)
    }

    @Test func theCoachLineFollowsTheDay() {
        #expect(TodayLines.coach(for: summary(), hour: 9).first == "Lift today.")
        #expect(TodayLines.coach(for: summary(), hour: 9).contains("23g protein to go."))
        var rested = summary(protein: 90)
        rested.session = nil
        #expect(TodayLines.coach(for: rested, hour: 9) == ["All set today.", "Rest well."])
    }

    @Test func coachLinesStayShortAndPlain() {
        for hour in [7, 13, 19] {
            for line in TodayLines.coach(for: summary(), hour: hour) {
                #expect(line.count <= 28 && !line.contains("!"), "\\(line)")
            }
        }
    }

    @Test func theOpeningNamesHerAndTheGap() {
        let text = TodayLines.opening(for: summary(), hour: 9)
        #expect(text.hasPrefix("Good morning, Anna."))
        #expect(text.contains("23g short on protein"))
    }
}
