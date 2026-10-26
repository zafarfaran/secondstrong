import Testing
@testable import SSCore

@Suite struct CheckInTests {
    private var anna: TodaySummary {
        var s = TodaySummary.sample
        s.openThread = "eggs at lunch"
        return s
    }

    private func kinds(_ list: [CheckInMessage]) -> [CheckIn] { list.map(\.kind) }

    @Test func nothingIsSentBeforeItsTime() {
        #expect(CheckInPlanner.due(settings: .standard, summary: anna, minuteOfDay: 7 * 60).isEmpty)
        #expect(kinds(CheckInPlanner.due(settings: .standard, summary: anna, minuteOfDay: 8 * 60 + 30)) == [.morning])
    }

    @Test func theDayBuildsUpInOrder() {
        let list = CheckInPlanner.due(settings: .standard, summary: anna, minuteOfDay: 13 * 60)
        #expect(kinds(list) == [.morning, .midday])   // the cap of two keeps the protein check ahead of the follow-up
        var open = CheckInSettings.standard
        open.dailyCap = 3
        #expect(kinds(CheckInPlanner.due(settings: open, summary: anna, minuteOfDay: 13 * 60)) == [.morning, .followUp, .midday])
    }

    @Test func theCapAndQuietHoursAreRespected() {
        var s = CheckInSettings.standard
        s.dailyCap = 1
        s.evening = true
        #expect(CheckInPlanner.due(settings: s, summary: anna, minuteOfDay: 23 * 60).count == 1)
        s.dailyCap = 3
        s.quietFrom = 8
        s.quietTo = 14
        #expect(CheckInPlanner.due(settings: s, summary: anna, minuteOfDay: 13 * 60).isEmpty)
    }

    @Test func ignoredMessagesMakeTheCoachBackOff() {
        let quiet = CheckInPlanner.due(settings: .standard, summary: anna, minuteOfDay: 13 * 60, ignoredInARow: 3)
        #expect(quiet.count == 1)
    }

    @Test func turnedOffCheckInsAreNotSent() {
        var s = CheckInSettings.standard
        s.morning = false; s.midday = false; s.followUp = false
        #expect(CheckInPlanner.due(settings: s, summary: anna, minuteOfDay: 13 * 60).isEmpty)
    }

    @Test func theProteinCheckOnlyComesWhenSheIsAWayOff() {
        var s = anna
        s.proteinGrams = 80
        var open = CheckInSettings.standard
        open.dailyCap = 3
        #expect(!kinds(CheckInPlanner.due(settings: open, summary: s, minuteOfDay: 13 * 60)).contains(.midday))
    }

    @Test func aFollowUpNeedsSomethingToFollowUp() {
        var s = anna
        s.openThread = nil
        var open = CheckInSettings.standard
        open.dailyCap = 3
        #expect(!kinds(CheckInPlanner.due(settings: open, summary: s, minuteOfDay: 13 * 60)).contains(.followUp))
    }

    @Test func noMessageTalksAboutWeightOrCalories() {
        var free = anna
        free.calorieTarget = nil
        var all = CheckInSettings.standard
        all.dailyCap = 3; all.evening = true
        var texts = CheckInPlanner.due(settings: all, summary: free, minuteOfDay: 22 * 60).map(\.text)
        texts.append(CheckInPlanner.afterSession(summary: free).text)
        for text in texts {
            let lower = text.lowercased()
            for word in ["weight", "kg", "calorie", "kcal", "diet"] { #expect(!lower.contains(word), "\(text)") }
            #expect(!lower.split(whereSeparator: { !$0.isLetter }).contains("lose"), "\(text)")
            #expect(!text.contains("!"))
        }
    }

    @Test func afterASessionTheCoachWritesOnce() {
        let message = CheckInPlanner.afterSession(summary: anna)
        #expect(message.kind == .afterSession && message.text.contains("Upper body"))
    }

    @Test func quietHoursWrapPastMidnight() {
        let s = CheckInSettings.standard
        #expect(s.isQuiet(minuteOfDay: 22 * 60) && s.isQuiet(minuteOfDay: 3 * 60) && !s.isQuiet(minuteOfDay: 12 * 60))
    }
}
